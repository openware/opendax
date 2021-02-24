#!/bin/bash -x

sudo -u deploy bash <<EOS
  source /home/deploy/.rvm/scripts/rvm

  export DOCKER_CLIENT_TIMEOUT=120
  export COMPOSE_HTTP_TIMEOUT=120

  cd /home/deploy/opendax
  gem install bundler
  bundle install
  rake service:all
EOS
