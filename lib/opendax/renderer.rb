# frozen_string_literal: true

require 'openssl'
require 'sshkey'
require 'pathname'
require 'yaml'
require 'base64'
require 'fileutils'

module Opendax
  # Renderer is class for rendering Opendax templates.
  class Renderer
    TEMPLATE_PATH = Pathname.new('./templates')

    BARONG_KEY = 'config/secrets/barong.key'
    APPLOGIC_KEY = 'config/secrets/applogic.key'
    SSH_KEY = 'config/secrets/app.key'

    def render
      @config ||= config
      @utils  ||= utils
      @name ||= @config['app']['name'].downcase
      @barong_key ||= OpenSSL::PKey::RSA.new(File.read(BARONG_KEY), '')
      @applogic_key ||= OpenSSL::PKey::RSA.new(File.read(APPLOGIC_KEY), '')
      @barong_private_key ||= Base64.urlsafe_encode64(@barong_key.to_pem)
      @barong_public_key  ||= Base64.urlsafe_encode64(@barong_key.public_key.to_pem)
      @applogic_private_key ||= Base64.urlsafe_encode64(@applogic_key.to_pem)
      @applogic_public_key ||= Base64.urlsafe_encode64(@applogic_key.public_key.to_pem)

      Dir.glob("#{TEMPLATE_PATH}/**/*.erb", File::FNM_DOTMATCH).each do |file|
        output_file = template_name(file)
        FileUtils.chmod 0o644, output_file if File.exist?(output_file)
        render_file(file, output_file)
        FileUtils.chmod 0o444, output_file if @config['render_protect']
      end
    end

    def render_file(file, out_file)
      puts "Rendering #{out_file}"
      result = ERB.new(File.read(file), trim_mode: '-').result(binding)
      dir = File.dirname(out_file)
      FileUtils.mkdir(dir) unless Dir.exist?(dir)
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
      return if File.file?(filename)

      key = SSHKey.generate(type: 'RSA', bits: 2048)
      File.write(filename, key.private_key)
      File.write("#{filename}.pub", key.ssh_public_key) if public
    end

    def config
      YAML.load_file('./config/app.yml')
    end

    def utils
      YAML.load_file('./config/utils.yml')
    end
  end
end
