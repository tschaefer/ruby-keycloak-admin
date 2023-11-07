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
    class InternalServerStandardError < StandardError; end # :nodoc:
    class ServiceUnavailableError < StandardError; end # :nodoc:
    class MethodNotAllowedError < StandardError; end # :nodoc:

    class << self
      def raise_error(response)
        error_classes = {
          400 => BadRequestError,
          401 => UnauthorizedError,
          403 => ForbiddenError,
          404 => NotFoundError,
          405 => MethodNotAllowedError,
          409 => ConflictError,
          500 => InternalServerStandardError,
          503 => ServiceUnavailableError
        }
        error_class = error_classes[response.code] || StandardError
        error_message = response.parsed_response['errorMessage'] || 'Unknown error'

        raise error_class, error_message
      end
    end
  end
end
