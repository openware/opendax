namespace :db do

  def mysql_cli
    return "mysql -u root -h db -P 3306 -pchangeme"
  end

  desc 'Create database'
  task :create do
    sh 'docker-compose run --rm peatio bundle exec rake db:create'
    sh 'docker-compose run --rm barong bundle exec rake db:create'
  end

  desc 'Load database dump'
  task :load => :create do
    sh %Q{docker-compose run --rm db /bin/sh -c "#{mysql_cli} peatio_production < /docker-entrypoint-initdb.d/peatio_production.sql"}
    sh %Q{docker-compose run --rm db /bin/sh -c "#{mysql_cli} barong_production < /docker-entrypoint-initdb.d/barong_production.sql"}
    sh 'docker-compose run --rm peatio bundle exec rake db:migrate'
    sh 'docker-compose run --rm barong bundle exec rake db:migrate'
  end

  desc 'Drop all databases'
  task :drop do
    sh %q(docker-compose run --rm db /bin/sh -c "mysql -u root -h db -P 3306 -pchangeme -e 'DROP DATABASE peatio_production'")
    sh %q(docker-compose run --rm db /bin/sh -c "mysql -u root -h db -P 3306 -pchangeme -e 'DROP DATABASE barong_production'")
  end

  desc 'Database Console'
  task :console do
    sh "docker-compose run --rm db #{mysql_cli}"
  end
end
