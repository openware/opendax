# Install OpenDax in Ubuntu 18.04

## Step 1: Install Docker

To install Docker you will need to do those steps with `sudo` or login as root user with `sudo -i`

Create a Unix user for holding your application
```
groupadd app
useradd -d /home/app -s `which bash` -g app -m app
```

### Installing from apt-get

First, update your existing list of packages:

```
apt update
```

Next, install a few prerequisite packages which let apt use packages over HTTPS:

```
apt install apt-transport-https ca-certificates curl software-properties-common
```

Then add the GPG key for the official Docker repository to your system:

```
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
```

Add the Docker repository to APT sources:

```
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
```

Next, update the package database with the Docker packages from the newly added repo:

```
apt update
```

Make sure you are about to install from the Docker repo instead of the default Ubuntu repo:

Finally, install Docker:

```
apt install docker-ce
```

Docker should now be installed, the daemon started, and the process enabled to start on boot. Check that it's running:

```
systemctl status docker
```

Add your app user into the docker group

```
usermod -aG docker app
```

## Step 2: Install Docker Compose

Run this command to download the latest version of Docker Compose:

```
curl -L "https://github.com/docker/compose/releases/download/1.23.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

chmod +x /usr/local/bin/docker-compose
```

## Step 3: Clone OpenDax

Login to your app user:
```
su - app
```

Clone opendax repository
```
cd $HOME
git clone https://github.com/rubykube/opendax.git
cd opendax
```

## Step 4: Clone your frontend

Edit config file `config/app.yml`
