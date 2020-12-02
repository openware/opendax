# Troubleshoot barong authorization process and envoy routing

## Architecture overview

Before establishing a connection to a microservice (for example ***rango***) envoy verifies the authorization by sending a request to ***barong authz***. Barong authz verifies the cookie (when using the UI) and the HMAC signature (when using API) and returns a signed token (JWT) if everything is valid.

![OpenDAX authorization](./images/OpenDAX-authorization.png)


## Enable envoy debug logs

To troubleshoot connection problems with a microservice of the stack, you can enable envoy logs to understand in which step the connection problem appears.

To do so you need to:

1. Edit *templates/compose/gateway.yaml.erb*

2. Change *info* by *debug* in the following lines:

```yaml
    command: /usr/local/bin/envoy -l debug -c /etc/envoy/envoy.yaml
```

3. Render the configuration files

```bash
rake render:config
```

4. Restart envoy

```bash
docker-compose up -dV gateway
```

5. Finally you can inspect the envoy logs

```bash
docker-compose logs -f --tail 100 gateway
```

Here are the relevant logs:

1. Initial websocket connection
```log
gateway_1               | [2020-12-02 07:50:30.169][13][debug][http] [source/common/http/conn_manager_impl.cc:580] [C184][S12609685784760114286] request headers complete (end_stream=false):
gateway_1               | ':authority', 'www.app.local'
gateway_1               | ':path', '/api/v2/ranger/private/?stream=global.tickers'
gateway_1               | ':method', 'GET'
gateway_1               | 'user-agent', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.66 Safari/537.36'
gateway_1               | 'accept-encoding', 'gzip, deflate'
gateway_1               | 'accept-language', 'en-US,en;q=0.9,fr;q=0.8'
gateway_1               | 'cache-control', 'no-cache'
gateway_1               | 'connection', 'Upgrade'
gateway_1               | 'cookie', '_barong_session=4cff598ee40d3d2ec38875ddc904fc46'
gateway_1               | 'origin', 'http://www.app.local'
gateway_1               | 'pragma', 'no-cache'
gateway_1               | 'sec-websocket-key', 'b16LunIyXls4CtNZ1lYWsw=='
gateway_1               | 'sec-websocket-extensions', 'permessage-deflate; client_max_window_bits'
gateway_1               | 'sec-websocket-version', '13'
gateway_1               | 'upgrade', 'websocket'
gateway_1               | 'x-forwarded-for', '172.20.0.1'
gateway_1               | 'x-forwarded-host', 'www.app.local'
gateway_1               | 'x-forwarded-port', '80'
gateway_1               | 'x-forwarded-proto', 'ws'
gateway_1               | 'x-forwarded-server', '41e065adb32e'
gateway_1               | 'x-real-ip', '172.20.0.1'
```

2. Request to Barong authz
```log
gateway_1               | [2020-12-02 07:50:30.183][13][debug][router] [source/common/router/router.cc:320] [C0][S3254558628791445120] cluster 'barong' match for URL '/api/v2/auth/api/v2/ranger/private/?stream=global.tickers'
gateway_1               | [2020-12-02 07:50:30.184][13][debug][router] [source/common/router/router.cc:381] [C0][S3254558628791445120] router decoding headers:
gateway_1               | ':method', 'GET'
gateway_1               | ':path', '/api/v2/auth/api/v2/ranger/private/?stream=global.tickers'
gateway_1               | ':authority', 'www.app.local'
gateway_1               | ':scheme', 'http'
gateway_1               | 'content-length', '0'
gateway_1               | 'x-forwarded-for', '172.20.0.1,172.20.0.8'
gateway_1               | 'cookie', '_barong_session=4cff598ee40d3d2ec38875ddc904fc46'
gateway_1               | 'user-agent', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.66 Safari/537.36'
gateway_1               | 'x-forwarded-host', 'www.app.local'
gateway_1               | 'x-forwarded-proto', 'ws'
gateway_1               | 'x-envoy-internal', 'true'
gateway_1               | 'x-envoy-expected-rq-timeout-ms', '1000'
```

3. Routing the connection to rango

```log
gateway_1               | [2020-12-02 07:50:30.220][13][debug][filter] [source/extensions/filters/http/ext_authz/ext_authz.cc:175] [C186][S2592169017517480399] ext_authz filter accepted the request
gateway_1               | [2020-12-02 07:50:30.220][13][debug][router] [source/common/router/router.cc:320] [C186][S2592169017517480399] cluster 'rango' match for URL '/api/v2/ranger/private/?stream=global.tickers'
gateway_1               | [2020-12-02 07:50:30.220][13][debug][router] [source/common/router/router.cc:381] [C186][S2592169017517480399] router decoding headers:
gateway_1               | ':authority', 'www.app.local'
gateway_1               | ':path', '/api/v2/ranger/private/?stream=global.tickers'
gateway_1               | ':method', 'GET'
gateway_1               | ':scheme', 'http'
gateway_1               | 'user-agent', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.66 Safari/537.36'
gateway_1               | 'accept-encoding', 'gzip, deflate'
gateway_1               | 'accept-language', 'en-US,en;q=0.9,fr;q=0.8'
gateway_1               | 'cache-control', 'no-cache'
gateway_1               | 'connection', 'Upgrade'
gateway_1               | 'cookie', '_barong_session=4cff598ee40d3d2ec38875ddc904fc46'
gateway_1               | 'origin', 'http://www.app.local'
gateway_1               | 'pragma', 'no-cache'
gateway_1               | 'sec-websocket-key', 'tocGzAPK8TACk8zzRX7n3g=='
gateway_1               | 'sec-websocket-extensions', 'permessage-deflate; client_max_window_bits'
gateway_1               | 'sec-websocket-version', '13'
gateway_1               | 'upgrade', 'websocket'
gateway_1               | 'x-forwarded-for', '172.20.0.1'
gateway_1               | 'x-forwarded-host', 'www.app.local'
gateway_1               | 'x-forwarded-port', '80'
gateway_1               | 'x-forwarded-proto', 'ws'
gateway_1               | 'x-forwarded-server', '41e065adb32e'
gateway_1               | 'x-real-ip', '172.20.0.1'
gateway_1               | 'content-length', '0'
gateway_1               | 'x-envoy-internal', 'true'
gateway_1               | 'x-request-id', '5b87e64a-4155-498e-916c-b8b998725a71'
gateway_1               | 'x-envoy-expected-rq-timeout-ms', '15000'
gateway_1               | ':status', '200'
gateway_1               | 'authorization', 'Bearer eyJhbGciOiJSUzI1NiJ9.eyJpYXQiOjE2MDY4OTU0MzAsImV4cCI6MTYwNjg5OTAzMCwic3ViIjoic2Vzc2lvbiIsImlzcyI6ImJhcm9uZyIsImF1ZCI6WyJwZWF0aW8iLCJiYXJvbmciXSwianRpIjoiNTllNGIwNTA3YTgyMGNjMzYzMTIiLCJ1aWQiOiJJRDVGRkE5OERDMjciLCJlbWFpbCI6ImFkbWluQGJhcm9uZy5pbyIsInJvbGUiOiJhZG1pbiIsImxldmVsIjozLCJzdGF0ZSI6ImFjdGl2ZSIsInJlZmVycmFsX2lkIjpudWxsfQ.Br6-yujI5MgU_BktVDYNaEPNtHOMxQZbNS89deQfxNiPPkx6B8ZUDXL9og5DQ6nWBExlHydyPPcCSUvO5BCth_UWiuttY_ldy7TIr_JrXT0td8WN8fq8QadOWFuJ7wvMEklRGVKQmvOrooHNKz_WwcY4xmaSO3SVgQdFSkmt626MOXmo9Wa3nYsL6EafCMe--9PHWop4L-B1w5ndvbGuGLbJaqEktXsudOX0A9Js2sKuHPxSe8QJKN5XwmOFPAWM28-VkaU5cmshMK2CwJaSRhVoL0gIi9VUGpFVVJ1ciD0VHjRfxuFTzph7utRuO_M9N-bweLL8YCCA8RkwlVyuLg'
gateway_1               | 'content-type', 'text/html; charset=utf-8'
gateway_1               | 'cache-control', 'no-cache'
gateway_1               | 'set-cookie', '_barong_session=4cff598ee40d3d2ec38875ddc904fc46; path=/; expires=Thu, 03 Dec 2020 07:50:30 GMT; HttpOnly'
gateway_1               | 'x-request-id', '8ff80928-9091-40b0-b6f0-c0b46f8d72fe'
gateway_1               | 'x-runtime', '0.031033'
gateway_1               | 'vary', 'Origin'
gateway_1               | 'transfer-encoding', 'chunked'
gateway_1               | 'x-envoy-upstream-service-time', '37'
```


## Authz configuration

In case of authorization problem check the following configuration files:

1. *config/barong/authz_rules.yml*
This file contains the default public endpoints and blocked endpoints.
If you have a problem accessing a public endpoint make sure the URL is present in the *rules.pass* section.

2. *templates/config/barong/seeds.yml.erb*
Check the *permissions* section to make sure the role of the user is allowed to access the resource.

Run the following command to apply the changes:

```bash
rake service:setup
```
