require 'faraday'
require 'json'
require 'yaml'

namespace :wallet do
  desc 'Generate ethereum wallet from a cryptonode'
  task :create, [:kind,:url,:secret] do |_, args|
    response = Faraday::Connection.new.post(args.url) do |request|
      request.headers["Content-Type"] = "application/json"
      request.body = "{\"jsonrpc\":\"2.0\",\"method\":\"personal_newAccount\",\"params\":[\"#{args.secret}\"],\"id\":1}"
      request.options.timeout = 300
    end
    address = JSON.parse(response.body)['result']
    puts "----- Generating a new #{args.kind} wallet -----", "Address: " + address

    @config['wallets']['eth'].find { |w| w['kind'] == args.kind }.update('address' => address, 'secret' => args.secret)

    File.open(CONFIG_PATH, 'w') {|f| f.write @config.to_yaml }
  end
end
