# AWS Installation Guide

## Step 1: Prepare the infrastructure

Infrastructural requirements for the installation are:

- An EC2 m5.xlarge **Debian** instance with a 200 GB disk storage
- An Elastic Container Registry repository with the baseapp image
- A DNS record to point to the machine(e.g. `example.domain.com`)

Create these resources before starting the installation and provision them with your RSA key to be able to connect to the VM instance using SSH.

## Step 2: Configure the instance

Connect to the instance over SSH as a `root`/`admin` user and perform the following steps.

### Core dependencies

```bash
apt-get update
apt-get install -y -q git tmux gnupg2 dirmngr dbus htop curl libmariadbclient-dev-compat build-essential
```

### Docker installation

```bash
curl -fsSL https://get.docker.com/ | bash
usermod -a -G docker $USER

COMPOSE_VERSION="1.23.2"
COMPOSE_URL="https://github.com/docker/compose/releases/download/$COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)"

curl -L "$COMPOSE_URL" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```

### User creation

```bash
 groupadd app
 useradd --create-home --home /home/app --shell /bin/bash \
   --gid app --groups docker,sudo app
```

### Ruby installation

As the `app` user(`sudo su app`), run:

```bash
gpg2 --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
curl -sSL https://get.rvm.io | bash -s stable
source /home/app/.rvm/scripts/rvm
rvm install --quiet-curl 2.6.1
rvm use --default 2.6.1
gem install bundler
```

## Step 3: Prepare the deployment

Clone the opendax repo to `/home/app`

```bash
git clone git@git.openware.com:opendax
```

`cd` into the `opendax` directory and prepare `config/app.yml` according to the [README](../README.md).

When the configuration is ready, run

```bash
bundle install
rake render:config
rake parity:import && \
  until rake wallet:create['deposit','http://0.0.0.0:8545','changeme']; do sleep 15; done && \
  rake wallet:create['hot','http://0.0.0.0:8545','changeme'] && \
  rake wallet:create['warm','http://0.0.0.0:8545','changeme'] && \
  rake render:config && \
  rake service:all && \
  chmod +x bin/install_webhook
  ./bin/install_webhook
```

After the deployment process is finished, the frontend would be accessible from the domain provided in the configuration.