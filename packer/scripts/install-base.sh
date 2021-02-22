#!/bin/bash -x

COMPOSE_VERSION="1.23.2"
COMPOSE_URL="https://github.com/docker/compose/releases/download/$COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)"

install_user_deploy() {
  sudo useradd -g users -s `which bash` -m deploy
}

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
usermod -a -G docker deploy
curl -L "$COMPOSE_URL" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
EOS
}

if id "deploy" >/dev/null 2>&1; then
  echo "user deploy exists"
else
  install_user_deploy
fi

install_core
log_rotation
install_docker
