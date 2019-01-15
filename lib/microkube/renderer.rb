require 'openssl'
require 'pathname'
require 'yaml'
require 'base64'

module Microkube
  # Renderer is class for rendering Microkube templates.
  class Renderer
    TEMPLATE_PATH  = Pathname.new('./templates')

    JWT_KEY = 'config/secrets/barong.key'.freeze

    def render
      generate_keys

      Dir.glob("#{TEMPLATE_PATH}/**/*.erb").each do |file|
        render_file(file, template_name(file))
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

    def generate_keys
      key = OpenSSL::PKey::RSA.generate(2048)
      File.open(JWT_KEY, 'w') { |file| file.puts(key) }
    end

    def config
      YAML.load_file('./config/app.yml')
    end
  end
end
