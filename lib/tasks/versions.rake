require 'faraday'

namespace :versions do
  desc 'Fetch global image versions and update config/app.yaml'
  task :update do
    unless @config['updateVersions']
      puts "To enable version updates, set updateVersions to true"
      next
    end

    puts "Fetching latest global versions"
    response = Faraday.get 'https://raw.githubusercontent.com/openware/versions/master/opendax/2-6/versions.yaml'

    if response.status >= 400 || response.status >= 500
      raise "Error fetching global versions, got #{response.body}"
    end

    versions = YAML.load(response.body)

    versions.each { |k, v| update_image_tag(k, v['image']['tag']) if @config['images'].key? k }

    File.write(CONFIG_PATH, YAML.dump(@config))

    puts 'Version update complete!'
  end
end

def update_image_tag(component, tag)
  image = @config['images'][component].split(':')
  image[-1] = tag

  @config['images'][component] = image.join(':')
end
