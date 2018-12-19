require_relative '../microkube/payload'
require 'faraday'

namespace :payload do
  desc 'Generate JWT'
  task :send, [:service, :image, :url] do |t, args|
    secret = ENV['WEBHOOK_JWT_SECRET']
    abort 'WEBHOOK_JWT_SECRET not set' if secret.to_s.empty?
    coder = Microkube::Payload.new(secret: secret)
    jwt = coder.generate!(service: args.service, image: args.image)
    response = Faraday.get "#{args.url}/deploy/#{jwt}"
    pp response.body
  end
end
