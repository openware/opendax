#!/bin/bash -x

COMPOSE_VERSION="1.23.2"
COMPOSE_URL="https://github.com/docker/compose/releases/download/$COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)"

install_opendax() {
  sudo -u deploy bash <<EOS
  cd /home/deploy
  source /home/deploy/.rvm/scripts/rvm
  rvm install --quiet-curl 2.6.1
  rvm use --default 2.6.1
  gem install bundler


  cd opendax

  bundle install
  rake render:config && \
  rake service:all && \
  rake service:daemons && \
  chmod +x bin/install_webhook
  sudo ./bin/install_webhook
EOS
}

install_opendax
