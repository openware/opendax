# Add your own tasks in files placed in lib/tasks ending in .rake

ENV['KITE_ENV'] ||= 'development'

Dir.glob('lib/tasks/*.rake').each do |task|
  load task
end
