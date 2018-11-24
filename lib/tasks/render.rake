require 'openssl'

namespace :render do
  desc 'Generate the RSA keys used during the installation'
  task :keys do
    puts 'Generating the RSA keys'
    ['./config/keys/barong.key', './config/keys/toolbox.key'].each do |file|
      unless File.exist?(file)
        key = OpenSSL::PKey::RSA.generate(2048)
        File.open(file, 'w') { |file| file.puts(key) }
      end
    end
  end

  desc 'Render configuration files'
  task :config => :keys do
    barong_key = OpenSSL::PKey::RSA.new(File.read('./config/keys/barong.key'), '')
    toolbox_key = OpenSSL::PKey::RSA.new(File.read('./config/keys/toolbox.key'), '')

    @jwt_private_key = Base64.urlsafe_encode64(barong_key.to_pem)
    @jwt_public_key  = Base64.urlsafe_encode64(barong_key.public_key.to_pem)
    @toolbox_jwt_private_key = Base64.urlsafe_encode64(toolbox_key.to_pem)
    @toolbox_jwt_public_key  = Base64.urlsafe_encode64(toolbox_key.public_key.to_pem)

    puts 'Rendering the config templates'
    Dir['config/tpl/*.erb'].each do |file|
      result = ERB.new(File.read(file), nil, '-').result(binding)
      File.write(File.join('config', file.split('/').last.sub('.erb', '')), result)
    end
  end
end
