
require_relative '../opendax/vault'

namespace :vault do
  desc 'Initialize, unseal and set secrets for Vault'
  task :setup do
    vault = Opendax::Vault.new
    vault_root_token = vault.setup
    unless vault_root_token.nil?
      @config["vault"]["root_token"] = vault_root_token
      File.open(CONFIG_PATH, 'w') { |f| YAML.dump(@config, f) }
    end
  end

  task :load_policies do
    vault = Opendax::Vault.new
    vault_tokens = vault.load_policies(@config["app"]["name"], @config["vault"]["root_token"])
    unless vault_tokens.empty?
      vault_tokens.each do |k, v|
        @config["vault"][k] = v
        File.open(CONFIG_PATH, 'w') { |f| YAML.dump(@config, f) }
      end
    end
  end
end
