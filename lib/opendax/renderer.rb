require 'openssl'
require 'sshkey'
require 'pathname'
require 'yaml'
require 'base64'

module Opendax
  # Renderer is class for rendering Opendax templates.
  class Renderer
    TEMPLATE_PATH = Pathname.new('./templates')

    BARONG_KEY = 'config/secrets/barong.key'.freeze
    APPLOGIC_KEY = 'config/secrets/applogic.key'.freeze
    SSH_KEY = 'config/secrets/app.key'.freeze

    def render
      Dir.glob("#{TEMPLATE_PATH}/**/*.erb").each do |file|
        output_file = template_name(file)
        render_file(file, output_file)
      end
    end

    def render_file(file, out_file)
      puts "Rendering #{out_file}"

      @config ||= config
      @utils  ||= utils
      @barong_key ||= OpenSSL::PKey::RSA.new(File.read(BARONG_KEY), '')
      @applogic_key ||= OpenSSL::PKey::RSA.new(File.read(APPLOGIC_KEY), '')
      @barong_private_key ||= Base64.urlsafe_encode64(@barong_key.to_pem)
      @barong_public_key  ||= Base64.urlsafe_encode64(@barong_key.public_key.to_pem)
      @applogic_private_key ||= Base64.urlsafe_encode64(@applogic_key.to_pem)
      @applogic_public_key ||= Base64.urlsafe_encode64(@applogic_key.public_key.to_pem)

      result = ERB.new(File.read(file), 0, '-').result(binding)
      File.write(out_file, result)
    end

    def ssl_helper(arg)
      @config['ssl']['enabled'] ? arg << 's' : arg
    end

    def template_name(file)
      path = Pathname.new(file)
      out_path = path.relative_path_from(TEMPLATE_PATH).sub('.erb', '')

      File.join('.', out_path)
    end

    def render_keys
      generate_key(BARONG_KEY)
      generate_key(APPLOGIC_KEY)
      generate_key(SSH_KEY, public: true)
    end

    def generate_key(filename, public: false)
      unless File.file?(filename)
        key = SSHKey.generate(type: 'RSA', bits: 2048)
        File.open(filename, 'w') { |file| file.puts(key.private_key) }
        File.open("#{filename}.pub", 'w') { |file| file.puts(key.ssh_public_key) } if public
      end
    end

    def config
      YAML.load_file('./config/app.yml')
    end

    def utils
      YAML.load_file('./config/utils.yml')
    end
  end
end
