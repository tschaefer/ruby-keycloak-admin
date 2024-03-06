# frozen_string_literal: true

module Keycloak
  module Admin
    class ConfigurationError < StandardError; end # :nodoc:
    class ConnectionFailedError < StandardError; end # :nodoc:
    class NotFoundError < StandardError; end # :nodoc:
    class UnauthorizedError < StandardError; end # :nodoc:
    class ForbiddenError < StandardError; end # :nodoc:
    class BadRequestError < StandardError; end # :nodoc:
    class ConflictError < StandardError; end # :nodoc:
    class InternalServerError < StandardError; end # :nodoc:
    class ServiceUnavailableError < StandardError; end # :nodoc:
    class MethodNotAllowedError < StandardError; end # :nodoc:
    class BadGatewayError < StandardError; end # :nodoc:

    class << self
      def raise_error(response)
        error_classes = {
          400 => BadRequestError,
          401 => UnauthorizedError,
          403 => ForbiddenError,
          404 => NotFoundError,
          405 => MethodNotAllowedError,
          409 => ConflictError,
          500 => InternalServerError,
          502 => BadGatewayError,
          503 => ServiceUnavailableError
        }
        error_class = error_classes[response.code] || StandardError

        raise error_class, error_message(response)
      end

      private

      def error_message(response)
        parsed_response = response.parsed_response

        return parsed_response if response.parsed_response.is_a?(String)

        if response.parsed_response.is_a?(Hash)
          return parsed_response['errorMessage'] ||
                 parsed_response['error'] ||
                 'Unknown error'
        end

        nil
      end
    end
  end
end
