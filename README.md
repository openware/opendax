![Cryptocurrency Exchange Platform - OpenDAX](https://github.com/openware/meta/raw/main/images/github_opendax.png)

<h3 align="center">
<a href="https://www.openware.com/sdk">Guide</a> <span>&vert;</span>
<a href="https://www.openware.com/sdk/api.html">API Docs</a> <span>&vert;</span>
<a href="https://www.openware.com/">Consulting</a> <span>&vert;</span>
<a href="https://t.me/peatio">Community</a>
</h3>
<h6 align="center"><a href="https://github.com/openware/opendax">OpenDAX Trading Platform</a></h6>

# OpenDAX

OpenDAX is an open-source cloud-native multi-service platform for building a Blockchain/FinTech exchange of digital assets, cryptocurrency and security tokens.

## Getting started with OpenDAX

### 1. Get a VM

Minimum VM requirements for OpenDAX:
 * 8GB of RAM (12GB recommended)
 * 4 cores vCPU (6 cores recommended)
 * 300GB disk space (SSD recommended)

A VM from any cloud provider like DigitalOcean, Vultr, GCP, AWS as well as any dedicated server with Ubuntu, Debian or Centos would work

### 2. Prepare the VM

#### 2.1 Create Unix user
SSH using root user, then create new user for the application
```bash
useradd -g users -s `which bash` -m app
```

#### 2.2 Install Docker and docker compose

We highly recommend using docker and compose from docker.com install guide instead of the system provided package, which would most likely be deprecated.

Docker follow instruction here: [docker](https://docs.docker.com/install/)
Docker compose follow steps: [docker compose](https://docs.docker.com/compose/install/)

#### 2.3 Install ruby in user app

##### 2.3.1 Change user using
```bash
su - app
```

##### 2.3.2 Clone OpenDAX
```bash
git clone https://github.com/openware/opendax.git
```

##### 2.3.3 Install RVM
```bash
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
curl -sSL https://get.rvm.io | bash -s stable
cd opendax
rvm install .
```

### 3. Bundle install dependencies

```bash
bundle install
rake -T # To see if ruby and lib works
```

Using `rake -T` you can see all available commands, and can create new ones in `lib/tasks`

### 4. Run everything

#### 4.1 Configure your domain
If using a VM you can point your domain name to the VM ip address before this stage.
Recommended if you enabled SSL, for local development edit the `/etc/hosts`

Insert in file `/etc/hosts`
```
0.0.0.0 www.app.local
```

#### 4.2 Bring everything up

```bash
rake service:all
```

You can login on `www.app.local` with the following default users from seeds.yaml
```
Seeded users:
Email: admin@barong.io, password: 0lDHd9ufs9t@
Email: john@barong.io, password: Am8icnzEI3d!
```

### [Optional] KYCAID

In order to  accelerate customer interaction, reduce risks and simplify business processes you can use KYC Verification Service from KYCaid.
KYC goal is to prevent fraud and to decline users that don’t fulfill certain standards of credibility.
To learn more about KYCaid and pricing you can visit their website - [kycaid.com](https://www.kycaid.com/)

#### How to configure KYCAID on the platform?

KYCAID is already integrated into our stack, to use it you'd need to create an account on [kycaid.com](https://www.kycaid.com/), and set up authentification creds there and the callback url: https://example.com/api/v2/barong/public/kyc

After that all you have to do is to change several lines in `config/app.yml`:

```yaml
kyc:
  provider: kycaid
  authorization_token: changeme             # your production API token from the 'Settings' section of kycaid.com
  sandbox_mode: true                        # 'true' for test environments - documents will be verified/rejected automatically, without payment for verification
  api_endpoint: https://api.kycaid.com/
```

##### Additional settings for KYCAID

* Be sure to check `BARONG_REQUIRED_DOCS_EXPIRE` ENV value inside `config/barong.env` to be `false` if you want to include `address` verification in your KYC process. You can set it to `true` if you need the document check only.
* Check if  you have the correct list of `document_types` in the `config/barong/barong.yml` file:
  - Passport
  - Identity card
  - Driver license
  - Address
* Frontend KYC steps can be configured in `templates/config/frontend/env.js.erb` via the `kycSteps` field
* Tower KYC labels can be configured in `templates/config/frontend/tower.js.erb` via the `labelSwitcher` field

## Usage

### Installation Wizard

Unless the installation wizard was disabled(`app.wizard_enabled` in `config/app.yml`), it will be displayed upon the first startup.
There, you can set the initial superadmin email and password, configure the exchange name and URL, and configure upstream markets from OpenDAX Cloud

### Tower configuration

After the initial configuration, you can manage all the configuration variables at `*exchange_url*/tower/settings/configurations`.

`public` and `private` scope configurations can be both viewed and updated while `secret` ones can only be updated to avoid credentials leakage.

As soon as any component's (barong, peatio, etc.) configuration is changed, it will restart and reload its config within 20 seconds.

### Terminal-based configuration

You can also alter platform configurations directly from the terminal.
To do this:
1. Open `config/secrets.yaml` or create a file with the same structure
2. Add or edit new configuration data for component(s) you'd like to update
3. Run `./tmp/kaisave --filepath *filepath*` to load all configurations from a given file

**Note: existing configurations would be overwritten by this process so make sure to only load relevant changes without resetting existing data with defaults for other components**

### Configuration files

All the OpenDAX deployment files have their confguration stored in `config/app.yml`.

#### app.yml

The following table lists the configurable parameters of the config/app.yml configuration file and its default values.

Parameter | Description | Default
--- | --- | ---
`app.name` | global application name | `"OpenDax"`
`app.domain` | base domain name | `app.local`
`app.subdomain` | subdomain | `www`
`app.wizard_enabled` | enable installation wizard | `true`
`app.show_landing` | enable/disable landing page display for the frontend application | `true`
`render_protect` | enable read-only mode for rendered files | `false`
`csrfEnabled` | enable CSRF protection on Barong | `false`
`ssl.enabled` | enable SSL certificate generation | `false`
`ssl.email` | email address used for SSL certificate issuing | `"support@example.com"`
`updateVersions` | update all image tags by fetching global ones for OpenDAX | `false`
`images` | Docker image tags per component
`vendor.frontend` | optional Git URL for a development frontend repo | `git@github.com:openware/baseapp.git`
`kyc.provider` |  KYC provider, can be `kycaid` or `local` | `kycaid`
`kyc.authorization_token` |  optional API token for KYCAID use | `changeme`
`kyc.sandbox` |  enable KYCAID test mode  | `true`
`kyc.api_endpoint` |  API endpoint for KYCAID | `https://api.kycaid.com/`
`vault.root_token` | Root Vault authentication token | `changeme `
`vault.peatio_rails_token` | Peatio Server Vault authentication token | `changeme `
`vault.peatio_crypto_token` | Peatio Daemons (cron_job, deposit, deposit_coin_address, withdraw_coin) Vault authentication token | `changeme `
`vault.peatio_upstream_token` | Peatio Upstream Daemon Vault authentication token | `changeme `
`vault.peatio_matching_token` | Peatio Daemons (matching, order_processor, trade_executor) Vault authentication token | `changeme `
`vault.barong_token` | Barong Vault authentication token | `changeme `
`vault.finex_engine_token` | Finex Engine Vault authentication token | `changeme `
`database.adapter`| database adapter kind either `mysql` or `postgresql` |`mysql`
`database.host` | database host name | `db`
`database.port` | database port | `3306 `
`database.user` | database username | `root`
`database.password` | database root password | `changeme`
`storage.provider` | object storage provider | `"Google"`
`storage.bucketname` | storage bucket name | `"opendax-barong-docs-bucket"`
`storage.endpoint` | S3-compatible storage API endpoint | `"https://fra1.digitaloceanspaces.com"`
`storage.region` | storage region | `"fra1"`
`storage.signatureVersion` | S3-compatible storage API signature version(2 or 4) | `"fra1"`
`storage.secretkey`, `storage.accesskey` | storage access keys | `"changeme"`
`twilio` | [Twilio](https://www.twilio.com/) SMS provider configs
`gaTrackerKey` | [Google Analytics](https://analytics.google.com/) tracker key inserted into the frontend app
`smtp` | SMTP configs used for sending platform emails
`captcha` | captcha configuration([Recaptcha](https://www.google.com/recaptcha) or [Geetest](https://www.geetest.com))
`wallets` | configs for wallets seeded during the initial deployment of Peatio
`parity` | Parity cryptonode configuration([learn more](https://openethereum.github.io))
`bitcoind` | Bitcoind cryptonode configuration
`litecoind` | Litecoind cryptonode configuration
`electrumd-btc` | Bitcoin electrumd server configuration([learn more](https://github.com/openware/images/tree/master/electrum))
`electrumd-ltc` | Litecoin electrumd server configuration([learn more](https://github.com/openware/images/tree/master/electrum-ltc))
`terraform.credentials` | local path to a GCP service account JSON key | `"~/safe/opendax.json"`
`terraform.project` | GCP project name | `"example-opendax"`

### utils.yml

The following table lists configurable parameters of the `config/utils.yml` file:

Parameter | Description | Default
--- | --- | ---
images | Docker image tags per component |
superset | Superset BI tool configs |
arke | Arke liquidity bot configs |

Once you're done with the configuration, render the files using `rake render:config`. You can easily apply your changes at any time by running this command.

    Note: be sure to append all the subdomains based on app.domain to your
    /etc/hosts file if you're running OpenDax locally

### Bringing up the stack

The OpenDAX stack can be brought up using two ways:

1. Bootstrap all the components at once using `rake service:all[start]`
2. Start every component one-by-one using `rake service:*component*[start]`

The components included in the stack are:

- `proxy` - [Traefik](https://traefik.io/), a robust cloud-native edge router/reverse proxy written in Go
- `backend` - [Vault](https://www.vaultproject.io), [MySQL](https://www.mysql.com), [Redis](https://redis.io) and [RabbitMQ](https://www.rabbitmq.com) grouped together
- `cryptonodes` - cryptocurrency nodes such as [parity](https://github.com/paritytech/parity-ethereum) **[Optional]**
- `daemons` - Peatio and Ranger daemons **[Optional]**
- `setup` - setup hooks for Peatio and Barong to run before the application starts (DB migration etc.)
- `app` - Peatio is the [crypto exchange software](https://www.openware.com/), [Barong](https://github.com/openware/barong) and the [Ambassador](https://www.getambassador.io) API gateway
- `frontend` - the frontend application located at `vendor/frontend`
- `tower` - the Tower admin panel application located at `vendor/tower`
- `monitoring` - [cAdvisor](https://github.com/google/cadvisor) and [Node Exporter](https://github.com/prometheus/node_exporter) monitoring tools **[Optional]**

For example, to start the `backend` services, you'll simply need to run `rake service:backend[start]`

    Note: all the components marked as [Optional] need to be installed using
    rake service:*component*[start] explicitly

Go ahead and try your own OpenDAX exchange deployment!

### Stopping and restarting components

Any component from the stack can be easily stopped or restarted using `rake service:*component*[stop]` and `rake service:*component*[restart]`.

For example, `rake service:frontend[stop]` would stop the frontend application container and `rake service:proxy[restart]` would completely restart the reverse proxy container.

# Managing component deployments

Each component has a config file (ex. `config/frontend/tower.js`) and a compose file (ex. `compose/frontend.yaml`).

All config files are mounted into respective component container, except from `config/app.yml` - this file contains all the neccessary configuration of opendax deployment

Compose files contain component images, environment configuration etc.

These files get rendered from their respective templates that are located under `templates` directory.

## How to update component image?

Modify `config/app.yml` with correct image and run `rake service:all`
This will rerender all the files from `templates` directory and restart all the running services.

Alternitavely you can update the following files:
  * `config/app.yml`
  * `templates/compose/*component*.yml`
  * `compose/*component*.yml`
And run `rake service:component[start]`

## How to update component config?

Modify `config/*component*/*config*` and run `rake service:component[start]`,
if you want the changes to be persistent, you also need to update `templates/config/*components*/*config*`

#### Render compose file
```
# Delete all generated files
git clean -fdx

# Re-generate config from config/app.yml values
rake render:config

# Restart the container you need to reload config
docker-compose up frontend -Vd
```

#### Clone the vendors and start
```
source ./bin/set-env.sh
rake vendor:clone
docker-compose -f compose/vendor.yaml up -d
```

## Vault management
Opendax uses [Vault Policies](https://www.vaultproject.io/docs/concepts/policies) to restrict components' access to sensitive data. Each component has its own Vault token which allows granular access only to the data required.

OpenDAX has 2 rake tasks for Vault management:
```sh
rake vault:setup # Initial Vault configuration (root token generation, unseal, endpoints configuration)
rake vault:load_policies # Components' Vault token generation
```

### Troubleshooting
#### Vault is sealed

In case of such error:
1. Run `rake vault:setup`
2. Restart the component

Make sure you're not using an existing Docker volume for Vault(i.e. one left after a different Vault container deployment):
```sh
docker volumes ps | grep vault
```

In case there are existing volumes, remove the running Vault container via `docker rm -f *id*` and run `docker volume rm -f *volume name*`
Afterward, run `docker-compose up -Vd vault` and re-run `rake vault:setup`.

#### Vault permission denied
Usually, this means that one of your Vault tokens has expired.

To fix the issue:
1. Run `rake vault:load_policies`
2. Run `rake render:config`
3. Restart Vault dependant components:

    ```
    docker-compose up -Vd barong peatio cron_job deposit deposit_coin_address withdraw_coin upstream

    # If you are using Finex
    docker-compose up -Vd finex-engine

    # If you are using Peatio Matching Engine
    docker-compose up -Vd matching order_processor trade_executor
    ```

## Terraform Infrastructure as Code Provisioning

You can easily deploy OpenDAX from scratch on Google Cloud Platform using [Terraform](https://www.terraform.io)!

To do this, just follow these simple steps:
  - Fill `app.yml` with correct values
  - Run `rake terraform:apply`
  - Access your VM from the GCP Cloud Console

To destroy the provisioned infrastructure, just run `rake terraform:destroy`

## Installer tool

```
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/openware/opendax/master/bin/install)"
```

## Using an OpenDAX deployment for local frontend development

If you'd like to use a real API from an existing OpenDAX deployment when developing frontend components(e.g. [baseapp](https://github.com/openware/baseapp)), modify `templates/config/gateway/envoy.yaml.erb` file the following way:

1. Set `allow_origin` as `"*"`

2. Configure all the needed HTTP methods in `allow_methods`. For example: `allow_methods: "PUT, GET, POST, DELETE, PATCH"`

3. Add `'total, page, x-csrf-token'` to `allow_headers` value

4. Configure `expose_headers` in a similar way `expose_headers:  "total, page, x-csrf-token"`

5. Add `allow_credentials: true` to your CORS configuration

After completing these steps, you should have the following config:
```
cors:
  allow_origin:
  - "*"
  allow_methods: "PUT, GET, POST, DELETE, PATCH"
  allow_headers: "content-type, x-grpc-web, total, page, x-csrf-token"
  expose_headers: "total, page, x-csrf-token"
  allow_credentials: true
```

Afterwards, apply the config onto your deployment:
```
rake render:config
docker-compose up -Vd gateway
```

## Happy trading with OpenDAX!

If you have any comments, feedback and suggestions, we are happy to hear from you here at GitHub or here: [crypto exchange software](https://www.openware.com/)

## 2.6 Migration guide

To migrate from 2.5 to 2.6, do the following:
1. Pull 2-6-stable branch
   While rebasing, rename your `vault.token` to `vault.root_token` in `config/app.yml`
2. Run `rake render:config`
3. Run `dc up -Vd vault`
4. Run `rake service:all`
