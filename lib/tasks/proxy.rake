namespace :proxy do
    desc 'Preapre proxy'
    task :prepare do
        File.new("config/acme.json", File::CREAT, 0600)
    end

    desc 'Run proxy'
    task :run do
        sh 'docker-compose up -d proxy'
    end
end

desc 'Run the micro'
task :proxy do
    puts '----- Starting proxy -----'
    Rake::Task["proxy:prepare"].invoke
    Rake::Task["proxy:run"].invoke
end