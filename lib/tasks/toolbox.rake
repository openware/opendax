namespace :toolbox do
  desc 'Run the toolbox'
  task :run do
    run_cmd = %w[docker-compose run --rm toolbox run]

    YAML.safe_load(File.read('config/toolbox.yaml'))
        .transform_keys { |k| '--' << k }
        .each_pair { |k, v| run_cmd << k << v.to_s }

    sh *run_cmd
  end
end
