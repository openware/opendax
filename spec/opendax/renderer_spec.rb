require 'opendax/renderer'

describe Opendax::Renderer do
  let(:renderer) { Opendax::Renderer.new }
  let(:fake_erb_result) { { 'data' => 'this is fake data'} }
  let(:config) do
    {
      'app' => {
        'name' => 'Opendax',
        'domain' => 'app.test'
      },
      'render_protect' => false,
      'ssl' => {
        'enabled' => 'true',
        'email' => 'support@example.com'
      },
      'images' => {
        'peatio' => 'rubykube/peatio:latest',
        'barong' => 'rubykube/barong:latest',
        'frontend' => 'rubykube/mikroapp:latest',
        'tower' => 'rubykube/tower:latest'
      },
      'vendor' => {
        'frontend' => 'https://github.com/rubykube/mikroapp.git'
      }
    }
  end

  it 'should load configuration' do
    allow(YAML).to receive(:load_file).and_return(config)
    expect(renderer.config).to eq(config)
  end

  describe '.config' do
    it 'should load configuration' do
      allow(YAML).to receive(:load_file).and_return(config)
      expect(renderer.config).to eq(config)
    end
  end

  describe '.generate_key' do
    it 'should generate a private RSA key by default' do
      renderer.generate_key('config/secrets/barong.key')
      expect(File).to exist('config/secrets/barong.key')
    end

    it 'should generate a public RSA key in addition when the flag is passed' do
      renderer.generate_key('config/secrets/app.key', public: true)
      expect(File).to exist('config/secrets/app.key')
      expect(File).to exist('config/secrets/app.key.pub')
    end
  end

  describe '.render_keys' do
    it 'should create files with private and public RSA keys' do
      renderer.render_keys
      expect(File).to exist('config/secrets/barong.key')
      expect(File).to exist('config/secrets/app.key')
      expect(File).to exist('config/secrets/app.key.pub')
    end
  end

  describe '.render_file' do
    it 'should render file' do
      expect(ERB).to receive(:new).once.and_call_original
      expect_any_instance_of(ERB).to receive(:result).once.and_return(fake_erb_result)
      expect(File).to receive(:write).with('./config/peatio.env', fake_erb_result).once.and_call_original

      renderer.render_file('./templates/config/peatio.env.erb', './config/peatio.env')
    end
  end

  describe '.template_name' do
    it 'should exclude "templates" directory' do
      file_name = renderer.template_name('./templates/config/peatio.env.erb')
      expect(file_name).not_to start_with('./templates')
    end

    it 'should return relative path to file' do
      file_name = renderer.template_name('./templates/compose/app.yaml.erb')
      expect(file_name).to start_with('.')
    end
  end

  let(:renderer) { Opendax::Renderer.new }

  describe '.render' do
    it 'should call exact amount of helper functions' do
      number_of_files = Dir.glob('./templates/**/*.erb', File::FNM_DOTMATCH).length
      expect(renderer).to receive(:render_file).exactly(number_of_files).times

      renderer.render
    end
  end
end
