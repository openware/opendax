#!/bin/bash -x

COMPOSE_VERSION="1.23.2"
COMPOSE_URL="https://github.com/docker/compose/releases/download/$COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)"

# Microkube bootstrap script
install_core() {
  sudo bash <<EOS
apt-get update
apt-get install -y -q git tmux dirmngr dbus htop curl libmariadbclient-dev-compat build-essential
EOS
}

# Docker installation
install_docker() {
  curl -fsSL https://get.docker.com/ | bash
  sudo bash <<EOS
usermod -aG docker $USER
curl -L "$COMPOSE_URL" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
EOS
}

create_user() {
  sudo bash <<EOS
  groupadd app
  useradd --create-home --home /home/app --shell /bin/bash \
    --gid app --groups docker,google-sudoers app
EOS
}


activate_gcloud() {
  sudo -u app bash <<EOS
  gcloud auth activate-service-account --key-file $HOME/gcloud-sa.json --quiet
  gcloud auth configure-docker --quiet
EOS
}

install_ruby() {
  sudo -u app bash <<EOS
  gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
  curl -sSL https://get.rvm.io | bash -s stable
EOS

}

install_microkube() {
  sudo -u app bash <<EOS
  cd /home/app
  source /home/app/.rvm/scripts/rvm
  rvm install --quiet-curl 2.5.3
  rvm use --default 2.5.3
  gem install bundler

  cp $HOME/git.key .
	echo 'ssh -i /home/app/git.key -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no \$*' > github-ssh
	chmod +x ./github-ssh
	chmod 0600 /home/app/git.key

  GIT_SSH='./github-ssh' git clone git@github.com:openware/microkube
  cd microkube
  cp $HOME/app.yml config/

  bundle install
  rake render:config && \
  rake geth:import && \
  until rake wallet:create['deposit','http://0.0.0.0:8545','changeme']; do sleep 15; done && \
  rake wallet:create['hot','http://0.0.0.0:8545','changeme'] && \
  rake wallet:create['warm','http://0.0.0.0:8545','changeme'] && \
  rake render:config && \
  rake service:all && \
  rake service:daemons && \
  ./bin/install_webhook

EOS
}

install_core
install_docker
create_user
activate_gcloud
install_ruby
install_microkube
