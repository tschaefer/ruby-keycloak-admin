# frozen_string_literal: true

require 'httparty'
require 'time'

require 'keycloak/admin/error'

module Keycloak
  module Admin
    class Agent # :nodoc: all
      include HTTParty
      headers 'Accept' => 'application/json', 'Content-Type' => 'application/json'
      debug_output $stdout if ENV['KEYCLOAK_ADMIN_DEBUG']

      attr_accessor :base_url, :username, :password, :realm, :grant_type, :always_terminate

      def initialize
        @base_url = 'http://localhost:8080'
        @realm = 'master'
        @username = 'nil'
        @password = 'nil'
        @grant_type = 'password'
        @always_terminate = false
      end

      def logout
        terminate_session
      end

      %i[get post put delete].each do |method|
        define_method method do |path, params: {}|
          request(method, path, params:)
        end
      end

      def request(method, path, params: {})
        refresh_session || create_session

        params[:headers] ||= {}
        params[:headers][:Authorization] = "Bearer #{@session['access_token']}"

        response = self.class.send(
          method,
          "#{@base_url}/#{path}",
          body: params[:body],
          headers: params[:headers]
        )

        terminate_session if @always_terminate

        Keycloak::Admin.raise_error(response) if !response.code.between?(200, 299)

        response.parsed_response
      end

      private

      def create_session
        return false if !session_expired?

        response = self.class.post(
          "#{@base_url}/realms/master/protocol/openid-connect/token",
          headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
          body: {
            grant_type: 'password',
            client_id: 'admin-cli',
            username: @username,
            password: @password
          }
        )

        Keycloak::Admin.raise_error(response) if !response.code.between?(200, 299)

        store_session(response)

        true
      end

      def refresh_session
        return false if !session_running?
        return false if refresh_expired?

        response = self.class.post(
          "#{@base_url}/realms/master/protocol/openid-connect/token",
          headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
          body: {
            grant_type: 'refresh_token',
            client_id: 'admin-cli',
            refresh_token: @session['refresh_token']
          }
        )

        return false if response.code.eql?(400)
        return Keycloak::Admin.raise_error(response) if !response.code.between?(200, 299)

        store_session(response)

        true
      end

      def terminate_session
        return false if !session_running?
        return false if refresh_expired?

        response = self.class.post(
          "#{@base_url}/realms/master/protocol/openid-connect/logout",
          headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
          body: {
            client_id: 'admin-cli',
            refresh_token: @session['refresh_token']
          }
        )

        @session = nil

        Keycloak::Admin.raise_error(response) if !response.code.between?(200, 299)

        true
      end

      def store_session(response)
        @session = response.parsed_response
        @session['expires_at'] = Time.now + @session['expires_in']
        @session['refresh_expires_at'] = Time.now + @session['refresh_expires_in']
      end

      def session_running?
        !@session.nil?
      end

      def session_expired?
        return true if @session.nil?

        Time.now > @session['expires_at']
      end

      def refresh_expired?
        return true if @session.nil?

        Time.now > @session['refresh_expires_at']
      end
    end
  end
end
