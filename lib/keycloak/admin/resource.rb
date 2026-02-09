# frozen_string_literal: true

require 'hashie'

module Keycloak
  module Admin
    class ResourceObject < Hashie::Mash
      disable_warnings
    end

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

        objects.map { |object| mash(object) }
      end

      ##
      # Create a new resource object.
      def create(attributes)
        @agent.post(resource, params: { body: attributes.to_json })
      end

      ##
      # Delete a resource object by id.
      def delete(id)
        @agent.delete("#{resource}/#{id}")
      end

      ##
      # Find resource objects by attributes, name and value.
      def find_by(lookup)
        objects = all

        lookup.each do |key, value|
          objects = objects.select do |object|
            match_value?(object, key, value)
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

        mash(object)
      end
      alias get find_by_id

      ##
      # Update a resource object by id.
      def update(id, attributes)
        @agent.put("#{resource}/#{id}", params: { body: attributes.to_json })
      end
      alias edit update

      private

      def resource
        raise NotImplementedError
      end

      def match_value?(object, key, value)
        return false if !object.key?(key)

        if value.is_a?(String)
          object[key].match?(value)
        else
          object[key] == value
        end
      end

      def mash(object)
        if object.is_a?(Array)
          object.map { |item| ResourceObject.new(item) }
        else
          ResourceObject.new(object)
        end
      end
    end
  end
end
