require 'erb'
require 'openssl'
require 'base64'

namespace :config do
  desc 'Render configuration files'
  task :render do
    files = [
      'config/peatio.env',
      'config/barong.env',
      'config/ranger.env',
      'config/toolbox.yaml',
      'config/peatio/management_api_v1.yml'
    ]

    ['./config/keys/barong.key', './config/keys/toolbox.key'].each do |file|
      unless File.exists?(file)
        key = OpenSSL::PKey::RSA.generate(2048)
        File.open(file, 'w') { |file| file.puts(key) }
      end
    end

    barong_key = OpenSSL::PKey::RSA.new(File.read('./config/keys/barong.key'), '')
    toolbox_key = OpenSSL::PKey::RSA.new(File.read('./config/keys/toolbox.key'), '')

    @jwt_private_key = Base64.urlsafe_encode64(barong_key.to_pem)
    @jwt_public_key  = Base64.urlsafe_encode64(barong_key.public_key.to_pem)
    @toolbox_jwt_private_key = Base64.urlsafe_encode64(toolbox_key.to_pem)
    @toolbox_jwt_public_key  = Base64.urlsafe_encode64(toolbox_key.public_key.to_pem)

    files.each do |file|
      result = ERB.new(File.read("#{file}.erb")).result(binding)
      File.write(file, result)
    end
  end
end
