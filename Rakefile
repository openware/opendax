require 'yaml'
require 'base64'
require 'erb'

@config = YAML.load_file('config/app.yml')

# Add your own tasks in files placed in lib/tasks ending in .rake
Dir.glob('lib/tasks/*.rake').each do |task|
  load task
end
