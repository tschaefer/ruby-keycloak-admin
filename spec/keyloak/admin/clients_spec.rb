# frozen_string_literal: true

require 'spec_helper'

require 'keycloak/admin/agent'
require 'keycloak/admin/clients'

RSpec.describe Keycloak::Admin::Clients, order: :defined do # rubocop:disable RSpec/SpecFilePathFormat
  before(:all) do # rubocop:disable RSpec/BeforeAfterAll
    agent = Keycloak::Admin::Agent.new
    agent.base_url = 'http://localhost:8080'
    agent.realm = 'master'
    agent.username = 'admin'
    agent.password = 'admin'

    described_class.agent = agent
  end

  let(:client) { { clientId: 'acme-client' } }

  around do |example|
    if ENV['VCR_OFF']
      example.run
    else
      VCR.use_cassette("clients/#{track}", record: :new_episodes) do
        example.run
      end
    end
  end

  describe '#create' do
    context 'with invalid attributes' do
      let(:track) { 'create/invalid' }

      it 'raises an error' do
        expect do
          described_class.create(clientId: 'acme-corp', invalid: true)
        end.to raise_error Keycloak::Admin::BadRequestError
      end
    end

    context 'with valid attributes' do
      let(:track) { 'create/valid' }

      it 'creates a client' do
        expect(described_class.create(client)).to be_nil
      end
    end

    context 'when client already exists' do
      let(:track) { 'create/exists' }

      it 'raises an error' do
        expect do
          described_class.create(client)
        end.to raise_error Keycloak::Admin::ConflictError
      end
    end
  end

  describe '#find_by', :aggregate_failures do
    context 'with invalid attributes' do
      let(:track) { 'find_by/invalid' }

      it 'returns empty list' do
        result = described_class.find_by(clientId: 'invalid')
        expect(result).to be_an(Array)
        expect(result.empty?).to be true
      end
    end

    context 'with valid attributes' do
      let(:track) { 'find_by/valid' }

      it 'returns list of clients' do
        result = described_class.find_by(clientId: 'acme-client')
        expect(result).to be_an(Array)
        expect(result.size).to be 1
        expect(result.first).to include client
      end
    end
  end

  describe '#find_by_id' do
    context 'with invalid id' do
      let(:track) { 'find_by_id/invalid' }

      it 'raises an error' do
        expect { described_class.find_by_id('47110815-42gg') }.to raise_error Keycloak::Admin::NotFoundError
      end
    end

    context 'with valid id' do
      let(:track) { 'find_by_id/valid' }
      let(:id) { described_class.all[2]['id'] }

      it 'returns a client' do
        expect(described_class.find_by_id(id)).to include client
      end
    end
  end

  describe '#update' do
    let(:id) { described_class.find_by(clientId: 'acme-client').first['id'] }

    context 'with invalid attributes' do
      let(:track) { 'update/invalid_attributes' }

      it 'raises an error' do
        expect { described_class.update(id, invalid: true) }.to raise_error Keycloak::Admin::BadRequestError
      end
    end

    context 'with invalid id' do
      let(:track) { 'update/invalid_id' }

      it 'raises an error' do
        expect do
          described_class.update('47110815-42gg', emailVerified: true)
        end.to raise_error Keycloak::Admin::NotFoundError
      end
    end

    context 'with valid attributes' do
      let(:track) { 'update/valid' }

      it 'updates a group' do
        expect(described_class.update(id, clientId: 'acme-corp-client')).to be_nil
      end
    end
  end

  describe '#delete' do
    let(:id) { described_class.find_by(clientId: 'acme-corp-client').first['id'] }

    context 'with invalid id' do
      let(:track) { 'delete/invalid' }

      it 'raises an error' do
        expect { described_class.delete('47110815-42gg') }.to raise_error Keycloak::Admin::NotFoundError
      end
    end

    context 'with valid id' do
      let(:track) { 'delete/valid' }

      it 'deletes a client' do
        expect(described_class.delete(id)).to be_nil
      end
    end
  end

  describe '#all' do
    let(:track) { 'all' }

    it 'returns an empty list', :aggregate_failures do
      all = described_class.all
      expect(all).to be_an Array
      expect(all.size).to be <= 7
    end
  end
end
