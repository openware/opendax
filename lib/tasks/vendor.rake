namespace :vendor do
  desc 'Clone the frontend and tower repositories into vendor/'
  task :clone do
    sh "git clone #{CONFIG['vendor']['frontend']} vendor/frontend || echo Frontend is already fetched"
    sh "git clone #{CONFIG['vendor']['tower']} vendor/tower || echo Tower is already fetched"
  end
end
