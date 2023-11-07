# frozen_string_literal: true

require 'keycloak/admin/resource'
require 'keycloak/admin/resource/pagination'

module Keycloak
  module Admin
    ##
    # Groups resource.
    #
    # The class is based on Keycloak::Admin::Resource and
    # Keycloak::Admin::Resource::Pagination. It provides following
    # additional methods:
    #
    # * ::add
    # * ::remove
    # * ::members
    module Groups
      class << self
        include Keycloak::Admin::Resource
        include Keycloak::Admin::Resource::Pagination

        ##
        # Add user to group.
        def add(id, user_id)
          @agent.put("/admin/realms/#{@agent.realm}/users/#{user_id}/groups/#{id}")

          true
        end

        ##
        # Remove user from group.
        def remove(id, user_id)
          @agent.delete("/admin/realms/#{@agent.realm}/users/#{user_id}/groups/#{id}")

          true
        end

        ##
        # Get group members.
        def members(id)
          objects = []
          (1..pages).each do |page|
            first = (page * MAX_ENTRIES) - MAX_ENTRIES
            objects << @agent.get("#{resource}/#{id}/members?first=#{first}&max=#{MAX_ENTRIES}")
          end

          objects.flatten.map { |object| to_struct(object) }
        end

        ##
        # Create subgroup.
        def subgroup(id, attributes)
          @agent.post("#{resource}/#{id}/children", params: { body: attributes.to_json })

          true
        end

        private

        def resource
          "admin/realms/#{@agent.realm}/groups"
        end
      end
    end
  end
end
