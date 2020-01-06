#!/bin/bash -x

COMPOSE_VERSION="1.23.2"
COMPOSE_URL="https://github.com/docker/compose/releases/download/$COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)"

# Opendax bootstrap script
install_core() {
  sudo bash <<EOS
apt-get update
apt-get install -y -q git tmux gnupg2 dirmngr dbus htop curl libmariadbclient-dev-compat build-essential
EOS
}

log_rotation() {
  sudo bash <<EOS
mkdir -p /etc/docker
echo '
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "10"
  }
}' > /etc/docker/daemon.json
EOS
}

# Docker installation
install_docker() {
  curl -fsSL https://get.docker.com/ | bash
  sudo bash <<EOS
usermod -a -G docker $USER
curl -L "$COMPOSE_URL" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
EOS
}

activate_gcloud() {
  sudo -u deploy bash <<EOS
  gcloud auth configure-docker --quiet
EOS
}

install_ruby() {
  sudo -u deploy bash <<EOS
  gpg2 --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
  curl -sSL https://get.rvm.io | bash -s stable
EOS

}

install_core
log_rotation
install_docker
activate_gcloud
install_ruby
