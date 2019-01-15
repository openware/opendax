namespace :vendor do
  desc 'Clone the frontend apps repos into vendor/'
  task :clone do
    puts '----- Clone the frontend apps repos -----'
    puts
    @config['vendor'].each do |name, repo_url|
      sh "git clone #{repo_url} vendor/#{name}"
      puts
    end
  end
end
