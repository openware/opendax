namespace :service do
  ENV['APP_DOMAIN'] = @config['app']['domain']

  @switch = Proc.new do |args, start, stop|
    case args.command
    when 'start'
      start.call
    when 'stop'
      stop.call
    when 'restart'
      stop.call
      start.call
    else
      puts "unknown command #{args.command}"
    end
  end

  desc 'Run Traefik (reverse-proxy)'
  task :proxy, [:command] do |task, args|
    args.with_defaults(:command => 'start')

    def start
      puts '----- Starting the proxy -----'
      File.new('config/acme.json', File::CREAT, 0600) unless File.exist? 'config/acme.json'
      sh 'docker-compose up -d proxy'
    end

    def stop
      puts '----- Stopping the proxy -----'
      sh 'docker-compose rm -fs proxy'
    end

    @switch.call(args, method(:start), method(:stop))
  end

  desc 'Run backend (vault db redis rabbitmq)'
  task :backend, [:command] do |task, args|
    args.with_defaults(:command => 'start')

    def start
      puts '----- Starting dependencies -----'
      sh 'docker-compose up -d vault db redis rabbitmq'
      sh 'docker-compose run --rm vault secrets enable totp \
              && docker-compose run --rm vault secrets disable secret \
              && docker-compose run --rm vault secrets enable -path=secret -version=1 kv \
              || echo Vault already enabled'
      sleep 7 # time for db to start, we can get connection refused without sleeping
    end

    def stop
      puts '----- Stopping dependencies -----'
      sh 'docker-compose rm -fs vault db redis rabbitmq'
    end


    @switch.call(args, method(:start), method(:stop))
  end

  desc '[Optional] Run peatio daemons (ranger, peatio daemons)'
  task :daemons, [:command] do |task, args|
    @daemons = %w[ranger withdraw_audit blockchain global_state deposit_collection deposit_collection_fees deposit_coin_address slave_book pusher_market pusher_member matching order_processor trade_executor withdraw_coin k]

    args.with_defaults(:command => 'start')

    def start
      puts '----- Starting peatio daemons -----'
      sh "docker-compose up -d #{@daemons.join(' ')}"
    end

    def stop
      puts '----- Stopping peatio daemons -----'
      sh "docker-compose rm -fs #{@daemons.join(' ')}"
    end

    @switch.call(args, method(:start), method(:stop))
  end

  desc '[Optional] Run cryptonodes'
  task :cryptonodes, [:command] do |task, args|
    args.with_defaults(:command => 'start')

    def start
      puts '----- Starting cryptonodes -----'
      sh 'docker-compose up -d geth'
    end

    def stop
      puts '----- Stopping cryptonodes -----'
      sh 'docker-compose rm -fs geth'
    end

    @switch.call(args, method(:start), method(:stop))
  end

  desc 'Run setup hooks for peatio and barong'
  task :setup, [:command] do |task, args|
    args.with_defaults(:command => 'start')

    def start
      puts '----- Running hooks -----'
      if @config['load_dump']
        sh 'docker-compose run --rm peatio bash -c "./bin/link_config && bundle exec rake db:create db:migrate"'
        sh 'docker-compose run --rm barong bash -c "./bin/init_config && bundle exec rake db:create db:migrate"'
        sh 'docker-compose exec db /bin/sh -c "mysql -u root -pchangeme peatio_production < /docker-entrypoint-initdb.d/peatio_production.sql"'
        sh 'docker-compose exec db /bin/sh -c "mysql -u root -pchangeme barong_production < /docker-entrypoint-initdb.d/barong_production.sql"'
      else
        sh 'docker-compose run --rm peatio bash -c "./bin/link_config && bundle exec rake db:create db:migrate db:seed"'
        sh 'docker-compose run --rm barong bash -c "./bin/init_config && bundle exec rake db:create db:migrate db:seed"'
      end
    end

    def stop
    end

    @switch.call(args, method(:start), method(:stop))
  end

  desc 'Run mikro app (barong, peatio)'
  task :app, [:command] => [:proxy, :backend, :setup] do |task, args|
    args.with_defaults(:command => 'start')

    def start
      puts '----- Starting app -----'
      sh 'docker-compose up -d peatio barong gateway'
    end

    def stop
      puts '----- Stopping app -----'
      sh 'docker-compose rm -fs peatio barong gateway'
    end

    @switch.call(args, method(:start), method(:stop))
  end

  desc 'Run the frontend application'
  task :frontend, [:command] do |task, args|
    args.with_defaults(:command => 'start')

    def start
      puts '----- Starting the frontend -----'
      sh 'docker-compose up -d frontend'
    end

    def stop
      puts '----- Stopping the frontend -----'
      sh 'docker-compose rm -fs frontend'
    end

    @switch.call(args, method(:start), method(:stop))
  end

  desc 'Run the tower application'
  task :tower, [:command] do |task, args|
    args.with_defaults(:command => 'start')

    def start
      puts '----- Starting the tower -----'
      sh 'docker-compose up -d tower'
    end

    def stop
      puts '----- Stopping the tower -----'
      sh 'docker-compose rm -fs tower'
    end

    @switch.call(args, method(:start), method(:stop))
  end

  desc '[Optional] Run utils (mailcatcher)'
  task :utils, [:command] do |task, args|
    args.with_defaults(:command => 'start')

    def start
      puts '----- Starting utils -----'
      sh 'docker-compose up -d mailcatcher'
    end

    def stop
      puts '----- Stopping Utils -----'
      sh 'docker-compose rm -fs mailcatcher'
    end

    @switch.call(args, method(:start), method(:stop))
  end

  desc 'Run the micro app with dependencies (does not run Optional)'
  task :all, [:command] do |task, args|
    args.with_defaults(:command => 'start')

    def start
      renderer = Microkube::Renderer.new
      renderer.render

      Rake::Task["service:proxy"].invoke('start')
      Rake::Task["service:backend"].invoke('start')
      Rake::Task["service:setup"].invoke('start')
      Rake::Task["service:app"].invoke('start')
      Rake::Task["service:frontend"].invoke('start')
      Rake::Task["service:tower"].invoke('start')
    end

    def stop
      Rake::Task["service:proxy"].invoke('stop')
      Rake::Task["service:backend"].invoke('stop')
      Rake::Task["service:setup"].invoke('stop')
      Rake::Task["service:app"].invoke('stop')
      Rake::Task["service:frontend"].invoke('stop')
      Rake::Task["service:tower"].invoke('stop')
    end

    @switch.call(args, method(:start), method(:stop))
  end
end
