require 'openssl'
require 'sshkey'
require 'pathname'
require 'yaml'
require 'base64'

module Microkube
  # Renderer is class for rendering Microkube templates.
  class Renderer
    TEMPLATE_PATH = Pathname.new('./templates')

    JWT_KEY = 'config/secrets/barong.key'.freeze
    SSH_KEY = 'config/secrets/kite.key'.freeze

    def render
      Dir.glob("#{TEMPLATE_PATH}/**/*.erb").each do |file|
        output_file = template_name(file)
        render_file(file, output_file)
      end
    end

    def render_file(file, out_file)
      puts "Rendering #{out_file}"

      @config ||= config
      @barong_key ||= OpenSSL::PKey::RSA.new(File.read(JWT_KEY), '')
      @jwt_private_key ||= Base64.urlsafe_encode64(@barong_key.to_pem)
      @jwt_public_key  ||= Base64.urlsafe_encode64(@barong_key.public_key.to_pem)

      result = ERB.new(File.read(file), 0, '-').result(binding)
      File.write(out_file, result)
    end

    def template_name(file)
      path = Pathname.new(file)
      out_path = path.relative_path_from(TEMPLATE_PATH).sub('.erb', '')

      File.join('.', out_path)
    end

    def render_keys
      generate_key(JWT_KEY)
      generate_key(SSH_KEY, public: true)
    end

    def generate_key(filename, public: false)
      key = SSHKey.generate(type: 'RSA', bits: 2048)
      File.open(filename, 'w') { |file| file.puts(key.private_key) }
      File.open("#{filename}.pub", 'w') { |file| file.puts(key.ssh_public_key) } if public
    end

    def config
      YAML.load_file('./config/app.yml')
    end
  end
end
