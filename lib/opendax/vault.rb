# frozen_string_literal: true

module Opendax
  class Vault
    POLICIES_NAMES = ["barong", "finex_engine", "peatio_rails", "peatio_crypto", "peatio_upstream", "peatio_matching", "kaigara", "sonic"]

    def vault_secrets_path
      'config/vault-secrets.yml'
    end

    def vault_exec(command)
      `docker-compose exec -T vault sh -c '#{command}'`
    end

    def secrets(command, endpoints, options = '')
      endpoints.each { |endpoint| vault_exec("vault secrets #{command} #{options} #{endpoint}") }
    end

    def setup
      puts '----- Checking Vault status -----'
      vault_status = YAML.safe_load(vault_exec('vault status -format yaml'))

      return if vault_status.nil?

      if vault_status['initialized']
        puts '----- Vault is initialized -----'
        begin
          vault_secrets = YAML.safe_load(File.read(vault_secrets_path))
        rescue SystemCallError => e
          puts 'Vault keys are missing'
          return
        end
        vault_root_token = vault_secrets['root_token']
        unseal_keys = vault_secrets['unseal_keys_b64'][0, 3]
      else
        puts '----- Initializing Vault -----'
        vault_init_output = YAML.safe_load(vault_exec('vault operator init -format yaml --recovery-shares=3 --recovery-threshold=2'))
        File.write(vault_secrets_path, YAML.dump(vault_init_output))
        vault_root_token = vault_init_output['root_token']
        unseal_keys = vault_init_output['unseal_keys_b64'][0, 3]
      end

      if vault_status['sealed']
        puts '----- Unsealing Vault -----'
        unseal_keys.each { |key| vault_exec("vault operator unseal #{key}") }
      else
        puts '----- Vault is unsealed -----'
      end

      return vault_root_token if vault_status['initialized']

      puts '----- Vault login -----'
      vault_exec("vault login #{vault_root_token}")

      puts '----- Configuring the endpoints -----'
      secrets('enable', %w[totp transit])
      secrets('disable', ['secret'])
      secrets('enable', ['kv'], '-version=2 -path=secret')
      vault_root_token
    end

    def load_policies(deployment_name, vault_root_token)
      puts '----- Vault login -----'
      vault_exec("vault login #{vault_root_token}")

      tokens = {}
      POLICIES_NAMES.each do |policy|
        name = "#{deployment_name.downcase}_#{policy}"

        puts "Loading #{name} policy..."
        vault_exec("vault policy write #{name} /tmp/policies/#{policy}.hcl")

        puts "Creating the #{name} token..."
        vault_token_create_output = YAML.safe_load(vault_exec("vault token create -policy=#{name} -renewable=true -ttl=240h -period=240h -format=yaml"))
        tokens["#{policy}_token"] = vault_token_create_output["auth"]["client_token"]
      end

      tokens
    end
  end
end
