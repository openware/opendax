#  App architecture

## Containers
### app::Peatio
Main app that serves as a matching engine. It is the one responsible for order matching, executing trades and serves as an accounting system

### app::Barong
oAuth 2.0 server. Serves as the main auth app and is capable of signing JWT request for elevated roles in a RBAC (peatio). It also has a KYC system.

### app::Applogic
Container that runs custom bussiness logic. This is a custom container to be built by us to integrate custom logic (Payment gateways, CRM integrations, custom notifications...)

### arke::Arke
Arke is a liquidity provider and arbitration platform. It connect to other exchanges (sources), analyses them and apply a copy strategy to another exchange (target), replicating values for trading pairs and buying them in order to provide liquidity.

### tower::Tower
Admin panel for Barong

### backend::DB
MySQL database to store data

### backend::Redis
Frontend in memory database used to improve speed and responsiveness of the main database.

### backend::RabbitMQ
Message broker and queue manage used to communicate different docker instances.

### backend::Vault
Secret and encrypted store for private keys, passwords and certificates. It allows to securely store secrets and access them on demand, logging and auditing every request.

### cryptonodes::Parity
Ethereum client written in RUST that supports both JSON-RPC HTTP and Websockets connection.

### cryptonodes::Bitcoind
Bitcoin client using JSON-RPC

### daemons::Ranger
Websocket notification system for Peatio

### utils::Postmaster
Mail server with direct integration with Sendgrid

### proxy::Envoy
API gateway for the whole stack

### proxy::Traefik
Reverse proxy with monitoring and dashboard used to route request between containers.

### superset::Superset
Bussiness intelligence web app.