# frozen_string_literal: true

require 'faraday'
require 'faraday_middleware'

KAISAVE_VERSION = '0.1.15'
KAISAVE_PATH = 'tmp/kaisave'
SECRETS_PATH = 'config/secrets.yaml'

namespace :kaisave do
  desc "Fetch the kaisave binary to #{KAISAVE_PATH}"
  task :fetch do
    if File.exist? KAISAVE_PATH
      puts 'kaisave is already present'
      next
    end

    client = Faraday.new("https://github.com/openware/kaigara/releases/download/#{KAISAVE_VERSION}/kaisave") do |c|
      c.use  FaradayMiddleware::FollowRedirects, limit: 5
      c.adapter Faraday.default_adapter
    end

    puts 'Fetching kaisave'
    response = client.get

    if response.status >= 400 || response.status >= 500
      raise "Error fetching kaisave, got #{response.body}"
    end

    File.write(KAISAVE_PATH, response.body)
    FileUtils.chmod 0o755, KAISAVE_PATH

    puts 'Kaisave fetched successfully'
  end

  desc "Save #{SECRETS_PATH} contents to Vault"
  task :save do
    ENV['KAIGARA_DEPLOYMENT_ID'] = @config['app']['name'].downcase
    ENV['KAIGARA_VAULT_ADDR'] ||= 'http://127.0.0.1:8200'
    ENV['KAIGARA_VAULT_TOKEN'] = @config['vault']['sonic_token']

    sh "./tmp/kaisave --filepath #{SECRETS_PATH}"
  end
end
