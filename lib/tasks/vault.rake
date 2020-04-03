
require_relative '../opendax/vault'

namespace :vault do
  desc 'Initialize, unseal and set secrets for Vault'
  task :setup do
    vault = Opendax::Vault.new
    vault_root_token = vault.setup
    unless vault_root_token.nil?
      @config["vault"]["token"] = vault_root_token
      File.open(CONFIG_PATH, 'w') { |f| YAML.dump(@config, f) }
    end
  end
end
