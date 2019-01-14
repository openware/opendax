require 'microkube/renderer'

describe MicroKube::Renderer do
  let(:renderer) { MicroKube::Renderer.new }
  let(:config) do
    {
      "app" => {
        "name" => "MicroKube",
        "domain" => "app.test"
      },
      "ssl" => {
        "enabled" => "true",
        "email" => "support@example.com"
      },
      "images" => {
        "peatio" => "rubykube/peatio:latest",
        "barong" => "rubykube/barong:latest",
        "frontend" => "rubykube/mikroapp:latest",
        "tower" => "rubykube/tower:latest"
      },
      "vendor" => {
        "frontend" => "https://github.com/rubykube/mikroapp.git"
      }
    }
  end

  # TODO: Finish tests.
  describe '.render' do
      it 'renders files from templates dir' do
        renderer.render
        allow(YAML).to receive(:load_file).with('config/app.yml').and_return(config)
      end
  end
end
