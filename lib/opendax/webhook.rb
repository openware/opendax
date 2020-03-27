require 'sinatra/base'
require 'json'
require 'yaml'

require_relative 'payload'
require_relative 'renderer'

class Webhook < Sinatra::Base
  CONFIG_PATH = 'config/app.yml'.freeze

  set :show_exceptions, false

  def initialize
    super
    @services = %w[barong peatio frontend tower applogic finex-engine finex-api]
    secret = ENV['WEBHOOK_JWT_SECRET']
    raise 'WEBHOOK_JWT_SECRET is not set' if secret.to_s.empty?
    @decoder = Opendax::Payload.new(secret: secret)
  end

  def update_config(service, image)
    config = YAML.load_file(CONFIG_PATH)
    config["images"][service] = image
    File.open(CONFIG_PATH, 'w') {|f| f.write config.to_yaml }
  end

  before do
    content_type 'application/json'
  end

  get '/deploy/ping' do
    'pong'
  end

  get '/deploy/:token' do |token|
    decoded = @decoder.safe_decode(token)
    return answer(400, 'invalid token') unless decoded

    service = decoded['service']
    image = decoded['image']

    return answer(400, 'service is not specified') unless service
    return answer(400, 'image is not specified') unless image
    return answer(404, 'unknown service') unless @services.include? service
    return answer(400, 'invalid image') if (%r(^(([-_\w\.]){,20}(\/|:))+([-\w\.]{,20})$) =~ image) == nil

    system "docker image pull #{image}"

    unless $?.success?
      system("docker image inspect #{image} > /dev/null")
      return answer(404, 'invalid image') unless $?.success?
    end

    if $?.success?
      update_config(service, image)

      renderer = Opendax::Renderer.new
      renderer.render

      system "docker-compose up -Vd #{service}"
    end

    return answer(500, 'could not restart container') unless $?.success?
    return answer(200, "service #{service} updated with image #{image}")
  end

  def answer(response_status, message)
    status response_status

    {
      message: message
    }.to_json
  end
end
