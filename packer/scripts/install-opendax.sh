#!/bin/bash -x

function enable_vault_unseal() {
  sudo cp /home/deploy/opendax/config/vault-unseal.service /etc/systemd/system/vault-unseal.service
  sudo systemctl daemon-reload
  sudo systemctl enable vault-unseal
}

sudo -u deploy bash <<EOS
  source /home/deploy/.rvm/scripts/rvm

  export DOCKER_CLIENT_TIMEOUT=120
  export COMPOSE_HTTP_TIMEOUT=120

  cd /home/deploy/opendax
  gem install bundler
  bundle install
  rake service:all
EOS

enable_vault_unseal
