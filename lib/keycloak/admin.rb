# frozen_string_literal: true

require 'keycloak/admin/version'
require 'keycloak/admin/agent'
require 'keycloak/admin/error'

require 'keycloak/admin/realms'
require 'keycloak/admin/clients'
require 'keycloak/admin/users'
require 'keycloak/admin/groups'

module Keycloak
  ##
  # Keycloak::Admin is a Ruby client for the Keycloak administration API.
  #
  # This is the main module. It provides methods to configure the connection to
  # any Keycloak service, as well as methods to manage and control the several
  # Keycloak resources.
  module Admin
    class << self
      ##
      # Configure Keycloak::Admin, the handler for all administration tasks.
      #
      # Provide Keycloak server base *url*, master realm admin user
      # *credentials* and id of *realm* to be managed.
      #
      #   Keycloak::Admin.configure do |config|
      #     config.username   = 'admin',
      #     config.password   = 'admin',
      #     config.realm      = 'zone',                         # default: master
      #     config.base_url   = 'https://keycloak.example.com'  # default: http://localhost:8080
      #   end
      def configure
        @agent ||= Keycloak::Admin::Agent.new
        yield @agent
        @configured = true

        true
      end

      ##
      # Verify if Keycloak::Admin is configured.
      def configured?
        @configured.nil? ? false : @configured
      end

      ##
      # Raise error if Keycloak::Admin is not configured.
      def configured!
        raise Keycloak::Admin::ConfigurationError, 'Keycloak::Admin is not configured' if !configured?

        true
      end

      ##
      # Reset Keycloak::Admin configuration.
      def reset!
        @agent&.logout
        @agent = nil
        @configured = nil
      end

      ##
      # Manage server realms. See Keycloak::Admin::Realms for usage.
      def realms
        configured!
        Keycloak::Admin::Realms.agent = @agent

        Keycloak::Admin::Realms
      end

      ##
      # Manage realm clients. See Keycloak::Admin::Clients for usage.
      def clients
        configured!
        Keycloak::Admin::Clients.agent = @agent

        Keycloak::Admin::Clients
      end

      ##
      # Manage realm users. See Keycloak::Admin::Users for usage.
      def users
        configured!
        Keycloak::Admin::Users.agent = @agent

        Keycloak::Admin::Users
      end

      ##
      # Manage realm groups. See Keycloak::Admin::Groups for usage.
      def groups
        configured!
        Keycloak::Admin::Groups.agent = @agent

        Keycloak::Admin::Groups
      end

      ##
      # Verify if the Keycloak server is ready.
      #
      # Beware, method returns +nil+ if the server does not respond (404 not
      # found) to health checks.
      def ready?
        configured!

        begin
          @agent.head('health/ready')
          true
        rescue Keycloak::Admin::NotFoundError
          nil
        rescue Keycloak::Admin::ServiceUnavailableError
          false
        end
      end
    end
  end
end
