# frozen_string_literal: true

require 'keycloak/admin/resource'

module Keycloak
  module Admin
    ##
    # Realms resource.
    #
    # The class is based on Keycloak::Admin::Resource and
    # Keycloak::Admin::Resource::Pagination. The method #find_by_id is renamed
    # to +find_by_name+.
    module Realms
      class << self
        include Keycloak::Admin::Resource
        alias find_by_name find_by_id
        undef find_by_id

        private

        def resource
          '/admin/realms'
        end
      end
    end
  end
end
