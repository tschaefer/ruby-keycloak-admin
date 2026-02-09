# Live testing

For live testing do following steps.

Start a local Keycloak server.

```sh
docker run --name keycloak --rm \
    --env KC_BOOTSTRAP_ADMIN_USERNAME=admin --env KC_BOOTSTRAP_ADMIN_PASSWORD=admin \
    --publish=8080:8080 dhi.io/keycloak:26.5.2-debian13-dev \
    start-dev --http-enabled=true
```

Run rspec with the specified environment variable.

```sh
VCR_OFF=true bundle exec rspec spec/scenario/pagination_spec.rb
```
