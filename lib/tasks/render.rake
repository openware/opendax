require 'openssl'
require 'pathname'

TEMPLATE_PATH = Pathname.new('./templates')
TEMPLATE_FILES = Rake::FileList["#{TEMPLATE_PATH}/**/*.erb"]
BARONG_KEY = 'config/secrets/barong.key'

namespace :render do
  file BARONG_KEY do |keyfile|
    puts 'Generating the RSA keys'
    key = OpenSSL::PKey::RSA.generate(2048)
    File.open(keyfile.name, 'w') { |file| file.puts(key) }
  end
  desc 'Generate the RSA keys used during the installation'
  task :secrets => [BARONG_KEY]

  def openkey
    return OpenSSL::PKey::RSA.new(File.read(BARONG_KEY), '')
  end

  def output(file)
    path = Pathname.new(file)
    outfile = path.relative_path_from(TEMPLATE_PATH).sub('.erb', '')
    return File.join('.', outfile)
  end

  def render(source, target)
    puts "Rendering #{target}"
    @barong_key ||= openkey()
    @jwt_private_key ||= Base64.urlsafe_encode64(@barong_key.to_pem)
    @jwt_public_key  ||= Base64.urlsafe_encode64(@barong_key.public_key.to_pem)
    result = ERB.new(File.read(source), 0, '-').result(binding)
    File.write(target, result)
  end

  TEMPLATE_FILES.each do |source|
    target = output(source)
    file target => source do
      render(source, target)
    end
    desc 'Render configuration files'
    task :config => [:secrets, target]
  end
end
