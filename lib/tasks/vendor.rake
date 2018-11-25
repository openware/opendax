namespace :vendor do
  desc 'Clone the frontend and tower repositories into vendor/'
  task :clone do
    puts '----- Cloning frontend and tower repos -----'
    sh "git clone #{CONFIG['vendor']['frontend']} vendor/frontend" unless File.exist? 'vendor/frontend'
    sh "git clone #{CONFIG['vendor']['tower']} vendor/tower" unless File.exist? 'vendor/tower'
  end
end
