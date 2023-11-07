# frozen_string_literal: true

require 'keycloak/admin/resource'

module Keycloak
  module Admin
    ##
    # Clients resource.
    #
    # The class is based on Keycloak::Admin::Resource and
    # Keycloak::Admin::Resource::Pagination.
    module Clients
      class << self
        include Keycloak::Admin::Resource

        private

        def resource
          "admin/realms/#{@agent.realm}/clients"
        end
      end
    end
  end
end
