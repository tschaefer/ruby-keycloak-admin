# Live testing

For live testing do following steps.

Start a local Keycloak server.

```sh
docker container run --name keycloak --publish 8080:8080 \
    --env KEYCLOAK_ADMIN=admin --env KEYCLOAK_ADMIN_PASSWORD=admin \
    --env KEYCLOAK_DATABASE_VENDOR=dev-file --rm bitnami/keycloak:latest
```

Run rspec with the specified environment variable.

```sh
VCR_OFF=true bundle exec rspec
```
