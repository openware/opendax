
namespace :run do
    desc 'Run deps'
    task :deps do
        puts '----- Starting dependencies -----'
        sh 'docker-compose up -d vault db redis rabbitmq mailcatcher ranger'
        sh 'docker-compose run --rm vault secrets enable totp || echo Vault already enabled'
        sleep 3
    end

    desc 'Run peatio daemons'
    task :daemons do
        puts '----- Starting peatio daemons -----'
        daemons = %w[withdraw_audit blockchain global_state deposit_collection deposit_collection_fees deposit_coin_address slave_book pusher_market pusher_member matching order_processor trade_executor withdraw_coin k]
        sh "docker-compose up -d #{daemons.join(' ')}"
    end

    desc 'Run cryptonodes'
    task :cryptonodes do
        puts '----- Starting cryptonodes -----'
        sh 'docker-compose up -d geth'
    end

    desc 'Run hooks'
    task :hooks do
        puts '----- Running hooks -----'
        sh 'docker-compose run --rm peatio bash -c "./bin/link_config && bundle exec rake db:create db:migrate db:seed"'
        # exec 'docker-compose run --rm barong bash -c "./bin/link_config && ./bin/setup"'
    end
end

desc 'Run the micro'
task :run do
    Rake::Task["config:render"].invoke
    Rake::Task["proxy"].invoke
    Rake::Task["run:deps"].invoke
    Rake::Task["run:daemons"].invoke
    # Rake::Task["run:cryptnodes"].invoke
    Rake::Task["run:hooks"].invoke

    sh 'docker-compose up -d peatio auth proxy gateway'
end

desc 'Stop all runnning docker contrainers'
task :down do
    sh 'docker-compose down'
end

desc 'Clean up all docker volumes'
task :clean do
    sh 'docker volume prune -f'
end
