# MicroKube

> Minimal stack for VM deployment.

## Getting started

### Install ruby with rvm

```
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
curl -sSL https://get.rvm.io | bash -s stable
```

### Bundle install depedencies

```
bundle
rake -T
```

### Run everything

```
rake service:all
```

Insert in file `/etc/hosts`
```
0.0.0.0 www.app.local
0.0.0.0 peatio.app.local
0.0.0.0 tower.app.local
0.0.0.0 monitor.app.local
```

You can login on `www.app.local` with the following default users from seeds.yaml
```
Seeded users:
Email: admin@barong.io, password: 0lDHd9ufs9t@
Email: john@barong.io, password: Am8icnzEI3d!
```

## Usage

### Initial configuration

All the MicroKube deployment files have their confguration stored in `config/app.yml`.

Feel free to fill it out with correct values:

| Parameter         | Description                                      |
| ----------------- | ------------------------------------------------ |
| `app.name`        | Global application name                          |
| `app.domain`      | Base domain name to be used                      |
| `ssl.enabled`     | Enable SSL certificate generation                |
| `ssl.email`       | Email address to use for SSL generation requests |
| `images`          | Application images tags                          |
| `vendor`          | Frontend application Git repo URL                |

Once you're done with the configuration, render the files using `rake render:config`. You can easily apply your changes at any time by running this command.

    Note: be sure to append all the subdomains based on app.domain to your
    /etc/hosts file if you're running MicroKube locally

### Bringing up the stack

The MicroKube stack can be brought up using two ways:

1. Bootstrap all the components at once using `rake service:all[start]`
2. Start every component one by one using `rake service:*component*[start]`

The components included in the stack are:

- `proxy` - [Traefik](https://traefik.io/), a robust cloud native edge router/reverse proxy written in Go
- `backend` - [Vault](https://www.vaultproject.io), [MySQL](https://www.mysql.com), [Redis](https://redis.io) and [RabbitMQ](https://www.rabbitmq.com) grouped together
- `cryptonodes` - cryptocurrency nodes such as [Geth](https://github.com/ethereum/go-ethereum) **[Optional]**
- `daemons` - Peatio daemons and Ranger **[Optional]**
- `utils` - utilities such as [Mailcatcher](https://mailcatcher.me/) **[Optional]**
- `setup` - setup hooks for Peatio and Barong to run before the application starts(DB migration etc.)
- `app` - [Peatio](https://github.com/rubykube/peatio), [Barong](https://github.com/rubykube/barong) and the [Ambassador](https://www.getambassador.io) API gateway
- `frontend` - the frontend application located at `vendor/frontend`
- `tower` - the Tower admin panel application located at `vendor/tower`

For example, to start the `backend` services, you'll simply need to run `rake service:backend[start]`

    Note: all the components marked as [Optional] need to be installed using
    rake service:*component*[start] explicitly

Go ahead and try your deployment on www.your.domain!

### Stopping and restarting components

Any component from the stack can be easily stopped or restarted using `rake service:*component*[stop]` and `rake service:*component*[restart]`.

For example, `rake service:frontend[stop]` would stop the frontend application container and `rake service:proxy[restart]` would completely restart the reverse proxy container.

### Accessing the deployment

    Note: Make sure your VM of choice has its firewall rules configured to let in
    HTTP and/or HTTPS traffic and your DNS entries are pointing at its external IP.

All the components with external endpoints are accessible by their respective subdomains based on the domain provided in the configuration:

- `www.base.domain` - frontend application and Peatio and Barong APIs mounted on `/api`
- `peatio.base.domain` - Peatio UI and API
- `barong.base.domain` - Barong API
- `tower.base.domain` - the Tower admin panel application
- `monitor.base.domain` - Traefik's dashboard useful for monitoring which components are enabled
- `ws.ranger.base.domain` - Ranger's WebSocket endpoint **[Optional]**
- `eth.base.domain` - Geth JSON RPC API **[Optional]**

## Using Vendor

Fill in the list of vendor to clone in app.yaml

#### Render compose file
```
rm compose/vendor.yaml
rake render:config
```

Review the generated file

#### Clone the vendors and start
```
source ./bin/set-env.sh
rake vendor:clone
docker-compose -f compose/vendor.yaml up -d
```

## Terraform Infrastructure as Code Provisioning

You can easily bring up Microkube from scratch on Google Cloud Platform using [Terraform](https://www.terraform.io)!

To do this, just follow these simple steps:
  - Fill `app.yml` with correct values
  - Run `rake terraform:apply`
  - Access your VM from the GCP Cloud Console
  - Have fun using it!

To destroy the provisioned infrastructure, just run `rake terraform:destroy`

## Installer tool

```
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/rubykube/microkube/master/bin/install)"
```
