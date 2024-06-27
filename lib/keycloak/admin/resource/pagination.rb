# frozen_string_literal: true

module Keycloak
  module Admin
    module Resource
      ##
      # Abstract class extension for Keycloak::Admin resources with methods
      # providing pagination.
      #
      # * #all
      module Pagination
        MAX_ENTRIES = 100

        ##
        # List all resources.
        def all
          objects = []
          (1..pages).each do |page|
            first = (page * MAX_ENTRIES) - MAX_ENTRIES
            objects << @agent.get("#{resource}?first=#{first}&max=#{MAX_ENTRIES}")
          end

          objects.flatten.map { |object| mash(object) }
        end

        private

        def count
          @agent.get("#{resource}/count")
        end

        def pages
          count = count()
          count = count['count'] if count.is_a?(Hash)

          return 0 if count.zero?
          return 1 if count <= MAX_ENTRIES

          pages = count / MAX_ENTRIES
          pages += 1 if (count % MAX_ENTRIES).positive?

          pages
        end
      end
    end
  end
end
