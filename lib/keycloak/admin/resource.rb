# frozen_string_literal: true

module Keycloak
  module Admin
    ##
    # Abstract class for Keycloak::Admin resources with common methods.
    #
    # * #all
    # * #create
    # * #count
    # * #delete
    # * #find_by, alias #lookup
    # * #find_by_id, alias #get
    # * #update, alias #edit
    module Resource
      attr_writer :agent

      ##
      # List all resource objects.
      def all
        objects = @agent.get(resource)

        objects.map { |object| to_struct(object) }
      end

      ##
      # Create a new resource object.
      def create(attributes)
        @agent.post(resource, params: { body: attributes.to_json })

        true
      end

      ##
      # Delete a resource object by id.
      def delete(id)
        @agent.delete("#{resource}/#{id}")

        true
      end

      ##
      # Find resource objects by attributes, name and value.
      def find_by(lookup)
        objects = all

        lookup.each do |key, value|
          objects = objects.select do |object|
            object.to_h.key?(key.to_sym) &&
              object.to_h[key.to_sym].match?(value)
          end
          break if !objects
        end

        objects || []
      end
      alias lookup find_by

      ##
      # Find a resource object by id.
      def find_by_id(id)
        object = @agent.get("#{resource}/#{id}")

        to_struct(object)
      end
      alias get find_by_id

      ##
      # Update a resource object by id.
      def update(id, attributes)
        @agent.put("#{resource}/#{id}", params: { body: attributes.to_json })

        true
      end
      alias edit update

      private

      def resource
        raise NotImplementedError
      end

      def to_struct(object)
        object.transform_keys!(&:to_sym)
        Struct.new(*object.keys).new(*object.values)
      end
    end
  end
end
