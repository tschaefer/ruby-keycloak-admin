# frozen_string_literal: true

require 'spec_helper'

require 'keycloak/admin/agent'

RSpec.describe Keycloak::Admin::Agent, order: :defined do # rubocop:disable RSpec/SpecFilePathFormat, RSpec/FilePath
  subject(:agent) do
    agent = described_class.new

    agent.base_url = 'http://localhost:8080'
    agent.realm = 'master'
    agent.username = 'admin'
    agent.password = 'admin'

    agent
  end

  around do |example|
    VCR.use_cassette("agent/#{track}", record: :new_episodes) do
      example.run
    end
  end

  describe '#request' do
    context 'with valid credentials and path' do
      let(:track) { 'valid' }

      it 'returns a response' do
        expect(agent.request(:get, 'admin/realms/master/clients')).to be_an Array
      end
    end

    context 'with invalid credentials' do
      let(:track) { 'unauthorized' }

      it 'raises an error' do
        agent.password = 'invalid'
        expect do
          agent.get('admin/realms/master/users')
        end.to raise_error Keycloak::Admin::UnauthorizedError
      end
    end

    context 'with invalid path' do
      let(:track) { 'not_found' }

      it 'raises an error' do
        expect do
          agent.get('admin/realms/master/invalid')
        end.to raise_error Keycloak::Admin::NotFoundError
      end
    end

    context 'with not allowed method' do
      let(:track) { 'method_not_allowed' }

      it 'raises an error' do
        expect do
          agent.put('admin/realms/master/users')
        end.to raise_error Keycloak::Admin::MethodNotAllowedError
      end
    end
  end
end
