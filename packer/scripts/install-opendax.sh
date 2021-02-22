#!/bin/bash -x

sudo -u deploy bash <<EOS
  source /home/deploy/.rvm/scripts/rvm

  cd /home/deploy/opendax
  gem install bundler
  bundle install
  rake render:config
  rake service:proxy
  rake service:backend
  docker-compose up -d influxdb
  docker-compose exec influxdb bash -c "cat peatio.sql | influx"
  sleep 5
  rake service:setup
  rake service:app
  rake service:frontend
  rake service:tower
  rake service:utils
  rake service:daemons
EOS
