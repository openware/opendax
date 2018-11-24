
namespace :run do
    desc 'Run backend (vault db redis rabbitmq mailcather ranger)'
    task :backends do
        puts '----- Starting dependencies -----'
        sh 'docker-compose up -d vault db redis rabbitmq ranger mailcatcher'
        sh 'docker-compose run --rm vault secrets enable totp \
            && docker-compose run --rm vault secrets disable secret \
            && docker-compose run --rm vault secrets enable -path=secret -version=1 kv \
            || echo Vault already enabled'
    end

    desc '[optional] Run peatio daemons'
    task :daemons do
        puts '----- Starting peatio daemons -----'
        daemons = %w[withdraw_audit blockchain global_state deposit_collection deposit_collection_fees deposit_coin_address slave_book pusher_market pusher_member matching order_processor trade_executor withdraw_coin k]
        sh "docker-compose up -d #{daemons.join(' ')}"
    end

    desc '[optional] Run cryptonodes'
    task :cryptonodes do
        puts '----- Starting cryptonodes -----'
        sh 'docker-compose up -d geth'
    end

    desc 'Run setup hooks for peatio and barong'
    task :setup do
        puts '----- Running hooks -----'
        sh 'docker-compose run --rm peatio bash -c "./bin/link_config && bundle exec rake db:create db:migrate db:seed"'
        sh 'docker-compose run --rm barong bash -c "./bin/init_config && bundle exec rake db:create db:migrate db:seed"'
    end

    desc 'Run mikro app (barong, peatio, frontend)'
    task :app do
        sh 'docker-compose up -d peatio auth proxy gateway barong frontend'
    end

    desc 'Run the micro app with dependencies (does not run optional)'
    task :all do
        # Rake::Task["config:render"].invoke rerenders credentials, need fix before invoking
        Rake::Task["proxy"].invoke
        Rake::Task["run:backends"].invoke
        sleep 7 # time for db to start, we can get connection refused without sleeping
        Rake::Task["run:setup"].invoke
        Rake::Task["run:app"].invoke
    end
end
