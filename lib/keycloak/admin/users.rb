# frozen_string_literal: true

require 'keycloak/admin/resource'
require 'keycloak/admin/resource/pagination'

module Keycloak
  module Admin
    ##
    # Users resource.
    #
    # The class is based on Keycloak::Admin::Resource and
    # Keycloak::Admin::Resource::Pagination. It provides following
    # additional methods:
    #
    # * ::join
    # * ::leave
    # * ::logout
    # * ::password
    # * ::sessions
    module Users
      class << self
        include Keycloak::Admin::Resource
        include Keycloak::Admin::Resource::Pagination

        ##
        # Add user to group.
        def join(id, group_id)
          @agent.put("#{resource}/#{id}/groups/#{group_id}")

          true
        end

        ##
        # Remove user from group.
        def leave(id, group_id)
          @agent.delete("#{resource}/#{id}/groups/#{group_id}")

          true
        end

        ##
        # User membership.
        def membership(id)
          objects = []
          (1..pages).each do |page|
            first = (page * MAX_ENTRIES) - MAX_ENTRIES
            objects << @agent.get("#{resource}/#{id}/groups?first=#{first}&max=#{MAX_ENTRIES}")
          end

          objects.flatten.map { |object| to_struct(object) }
        end

        ##
        # Logout user from all sessions.
        def logout(id)
          @agent.post("#{resource}/#{id}/logout")

          true
        end

        ##
        # Set new password for user.
        def password(id, attributes)
          # { temporary: false, value: 'password' }
          attributes[:type] = 'password'
          @agent.put("#{resource}/#{id}/reset-password", params: { body: attributes.to_json })

          true
        end

        ##
        # Get user sessions.
        def sessions(id)
          objects = @agent.get("#{resource}/#{id}/sessions")

          objects.map { |object| to_struct(object) }
        end

        private

        def resource
          "admin/realms/#{@agent.realm}/users"
        end
      end
    end
  end
end
