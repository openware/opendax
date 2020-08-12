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
      sleep 7 # time for db to start, we can get connection refused without sleeping
    end

    def stop
      puts '----- Stopping dependencies -----'
      sh 'docker-compose rm -fs vault db redis rabbitmq'
    end


    @switch.call(args, method(:start), method(:stop))
  end

  desc 'Run influxdb'
  task :influxdb, [:command] do |task, args|
    args.with_defaults(:command => 'start')

    def start
      puts '----- Starting influxdb -----'
      sh 'docker-compose up -d influxdb'
      sh 'docker-compose exec influxdb bash -c "cat peatio.sql | influx"'
    end

    def stop
      puts '----- Stopping influxdb -----'
      sh 'docker-compose rm -fs influxdb'
    end

    @switch.call(args, method(:start), method(:stop))
  end

  desc '[Optional] Run arke-maker'
  task :arke_maker, [:command] do |task, args|
    args.with_defaults(:command => 'start')

    def start
      puts '----- Starting arke -----'
      sh 'docker-compose up -d arke-maker'
    end

    def stop
      puts '----- Stopping arke -----'
      sh 'docker-compose rm -fs arke-maker'
    end

    @switch.call(args, method(:start), method(:stop))
  end

  desc '[Optional] Run peatio daemons (rango, peatio daemons)'
  task :daemons, [:command] do |_task, args|
    @daemons = %w[rango withdraw_audit blockchain cron_job upstream deposit deposit_coin_address withdraw_coin influx_writer]

    if @config['finex']['enabled']
      @daemons |= %w[finex-engine finex-api]
    else
      @daemons |= %w[matching order_processor trade_executor]
    end

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
      sh 'docker-compose up -d parity'
      if @config['bitcoind']['enabled']
        sh 'docker-compose up -d bitcoind'
      end
    end

    def stop
      puts '----- Stopping cryptonodes -----'
      sh 'docker-compose rm -fs parity'
      if @config['bitcoind']['enabled']
        sh 'docker-compose rm -fs bitcoind'
      end
    end

    @switch.call(args, method(:start), method(:stop))
  end

  desc 'Run setup hooks for peatio, barong'
  task :setup, [:command] => ['vault:setup'] do |task, args|
    if args.command != 'stop'
      Rake::Task["render:config"].execute
      puts '----- Running hooks -----'
      sh 'docker-compose run --rm peatio bash -c "./bin/link_config && bundle exec rake db:create db:migrate"'
      sh 'docker-compose run --rm peatio bash -c "./bin/link_config && bundle exec rake db:seed"'
      sh 'docker-compose run --rm barong bash -c "./bin/init_config && bundle exec rake db:create db:migrate"'
      sh 'docker-compose run --rm barong bash -c "./bin/link_config && bundle exec rake db:seed"'
    end
  end

  desc 'Run mikro app (barong, peatio)'
  task :app, [:command] => [:backend, :setup] do |task, args|
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

  desc '[Optional] Run utils (mailer)'
  task :utils, [:command] do |task, args|
    args.with_defaults(:command => 'start')

    def start
      puts '----- Starting utils -----'
      sh 'docker-compose up -d mailer'
    end

    def stop
      puts '----- Stopping Utils -----'
      sh 'docker-compose rm -fs mailer'
    end

    @switch.call(args, method(:start), method(:stop))
  end

  desc '[Optional] Run monitoring'
  task :monitoring, [:command] do |task, args|
    args.with_defaults(:command => 'start')

    def start
      puts '----- Starting monitoring -----'
      sh 'docker-compose up -d node_exporter'
      sh 'docker-compose up -d cadvisor'
    end

    def stop
      puts '----- Stopping monitoring -----'
      sh 'docker-compose rm -fs node_exporter'
      sh 'docker-compose rm -fs cadvisor'
    end

    @switch.call(args, method(:start), method(:stop))
  end

  desc '[Optional] Run superset'
  task :superset, [:command] do |task, args|
    args.with_defaults(:command => 'start')

    def start
      conf = @utils['superset']
      init_params = [
        '--app', 'superset',
        '--firstname', 'Admin',
        '--lastname', 'Superset',
        '--username', conf['username'],
        '--email', conf['email'],
        '--password', conf['password']
      ].join(' ')

      puts '----- Initializing Superset -----'
      sh [
        'docker-compose run --rm superset',
        'sh -c "',
        "fabmanager create-admin #{init_params}",
        '&& superset db upgrade',
        '&& superset init"'
      ].join(' ')

      puts '----- Starting Superset -----'
      sh 'docker-compose up -d superset'
    end

    def stop
      puts '----- Stopping Superset -----'
      sh 'docker-compose rm -fs superset'
    end

    @switch.call(args, method(:start), method(:stop))
  end
  desc 'Run the micro app with dependencies (does not run Optional)'
  task :all, [:command] => 'render:config' do |task, args|
    args.with_defaults(:command => 'start')

    def start
      Rake::Task["service:proxy"].invoke('start')
      Rake::Task["service:backend"].invoke('start')
      Rake::Task["service:influxdb"].invoke('start')
      puts 'Wait 5 second for backend'
      sleep(5)
      Rake::Task["service:setup"].invoke('start')
      Rake::Task["service:app"].invoke('start')
      Rake::Task["service:frontend"].invoke('start')
      Rake::Task["service:tower"].invoke('start')
      Rake::Task["service:utils"].invoke('start')
      Rake::Task["service:daemons"].invoke('start')
    end

    def stop
      Rake::Task["service:proxy"].invoke('stop')
      Rake::Task["service:backend"].invoke('stop')
      Rake::Task["service:influxdb"].invoke('stop')
      Rake::Task["service:setup"].invoke('stop')
      Rake::Task["service:app"].invoke('stop')
      Rake::Task["service:frontend"].invoke('stop')
      Rake::Task["service:tower"].invoke('stop')
      Rake::Task["service:utils"].invoke('stop')
      Rake::Task["service:daemons"].invoke('stop')
    end

    @switch.call(args, method(:start), method(:stop))
  end
end
