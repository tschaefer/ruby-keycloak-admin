# frozen_string_literal: true

$LOAD_PATH << File.expand_path('lib', __dir__)
require 'keycloak/admin/version'

Gem::Specification.new do |spec|
  spec.name        = 'keycloak-admin'
  spec.version     = Keycloak::Admin::VERSION
  spec.platform    = Gem::Platform::RUBY
  spec.authors     = ['Tobias Schäfer']
  spec.email       = ['github@blackox.org']

  spec.summary     = 'Ruby Keycloack admin API wrapper.'
  spec.description = <<~DESC
    #{spec.summary}

    This gem provides a simple wrapper for the Keycloak admin API.

      * https://www.keycloak.org
      * https://www.keycloak.org/documentation
      * https://www.keycloak.org/docs-api/23.0.7/rest-api/index.html

  DESC
  spec.homepage    = 'https://github.com/tschaefer/keycloak-admin'
  spec.license     = 'MIT'

  spec.files                 = Dir['lib/**/*']
  spec.require_paths         = ['lib']
  spec.required_ruby_version = '>= 3.1'

  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.metadata['source_code_uri']       = 'https://github.com/tschaefer/keycloak-admin'
  spec.metadata['bug_tracker_uri']       = 'https://github.com/tschaefer/keycloak-admin/issues'

  spec.post_install_message = 'All your Keycloak are belong to us!'

  spec.add_dependency 'hashie', '~> 5.0.0'
  spec.add_dependency 'httparty', '~> 0.21.0'
end
