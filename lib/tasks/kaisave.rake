# frozen_string_literal: true

require 'faraday'
require 'faraday_middleware'

KAISAVE_VERSION = '0.1.15'
KAISAVE_PATH = 'tmp/kaisave'

namespace :kaisave do
  desc "Fetch the kaisave binary to #{KAISAVE_PATH}"
  task :fetch do
    if File.exist? KAISAVE_PATH
      puts 'kaisave is already present'
      next
    end

    client = Faraday.new("https://github.com/openware/kaigara/releases/download/#{KAISAVE_VERSION}/kaisave") do |c|
      c.use  FaradayMiddleware::FollowRedirects, limit: 5
      c.adapter Faraday.default_adapter
    end

    puts 'Fetching kaisave'
    response = client.get

    if response.status >= 400 || response.status >= 500
      raise "Error fetching kaisave, got #{response.body}"
    end

    File.write(KAISAVE_PATH, response.body)
    FileUtils.chmod 0o755, KAISAVE_PATH

    puts 'Kaisave fetched successfully'
  end
end
