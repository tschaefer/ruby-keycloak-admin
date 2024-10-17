# keycloak-admin

Ruby Keycloak admin API wrapper.

## Introduction

`Keycloak::Admin` is a Ruby client for the Keycloak administration API.

It provides functionality to manage Keycloak resources and objects.
Currently following resources are supported.

* Clients
* Groups
* Realms
* Users

In common creating, deleting and updating of resource objects as well as
fetching (by identifier) and searching by attributes is possible.

The `Users` interface additionally provides the functionality to list and
terminate all current sessions of a named users object.
Further the `Users` and `Groups` interface provide the methods to add,
remove a users object to a groups object and list memberships.

### Version

The current gem version equates the latest tested Keycloak version.

## Installation

```sh
 $ gem install --file --without development,test
 $ gem build
 $ VERSION=$(ruby -Ilib -e 'require "keycloak/admin/version"; puts Keycloak::Admin::VERSION')
 $ gem install --local keycloak-admin-${VERSION}.gem
```

## Usage

The required step is to set up a connection to a Keycloak service.

```ruby
require 'keycloak/admin'

Keycloak::Admin.configure do |config|
  config.username   = 'admin',
  config.password   = 'admin',
  config.realm      = 'zone',                         # default: master
  config.base_url   = 'https://keycloak.example.com'  # default: http://localhost:8080
end
```

Following example lists all users in the configured realm filtered by the
matching last name.

```ruby
Keycloak::Admin.users.find_by(lastName: 'Doe')
```

For further usage use `ri` or `rake doc` to create HTML documentation files.

## License

[MIT License](https://spdx.org/licenses/MIT.html)

## Is it any good?

[Yes.](https://news.ycombinator.com/item?id=3067434)
