namespace :docker do
    desc 'Stop all runnning docker contrainers'
    task :down do
        sh 'docker-compose down'
    end

    desc 'Clean up all docker volumes'
    task :clean do
        sh 'docker volume prune -f'
    end
end
