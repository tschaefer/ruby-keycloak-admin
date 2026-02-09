# frozen_string_literal: true

require 'spec_helper'

require 'keycloak/admin/agent'
require 'keycloak/admin/realms'

RSpec.describe Keycloak::Admin::Realms, order: :defined do # rubocop:disable RSpec/SpecFilePathFormat
  before(:all) do # rubocop:disable RSpec/BeforeAfterAll
    agent = Keycloak::Admin::Agent.new
    agent.base_url = 'http://localhost:8080'
    agent.realm = 'master'
    agent.username = 'admin'
    agent.password = 'admin'

    described_class.agent = agent
  end

  let(:realm) { { realm: 'acme-corp-realm' } }

  around do |example|
    if ENV['VCR_OFF']
      example.run
    else
      VCR.use_cassette("realms/#{track}", record: :new_episodes) do
        example.run
      end
    end
  end

  describe '#create' do
    context 'with invalid attributes' do
      let(:track) { 'create/invalid' }
      let(:exception) do
        if ENV['VCR_OFF']
          Keycloak::Admin::BadRequestError
        else
          Keycloak::Admin::InternalServerError
        end
      end

      it 'raises an error' do
        expect do
          described_class.create(realm: 'acme-corp-realm', invalid: true)
        end.to raise_error exception
      end
    end

    context 'with valid attributes' do
      let(:track) { 'create/valid' }

      it 'creates a client' do
        expect(described_class.create(realm)).to be_nil
      end
    end

    context 'when client already exists' do
      let(:track) { 'create/exists' }

      it 'raises an error' do
        expect do
          described_class.create(realm)
        end.to raise_error Keycloak::Admin::ConflictError
      end
    end
  end

  describe '#find_by', :aggregate_failures do
    context 'with invalid attributes' do
      let(:track) { 'find_by/invalid' }

      it 'returns empty list' do
        result = described_class.find_by(realm: 'invalid')
        expect(result).to be_an(Array)
        expect(result.empty?).to be true
      end
    end

    context 'with valid attributes' do
      let(:track) { 'find_by/valid' }

      it 'returns list of realms' do
        result = described_class.find_by(realm: 'acme-corp-realm')
        expect(result).to be_an(Array)
        expect(result.size).to be 1
        expect(result.first).to include realm
      end
    end
  end

  describe '#find_by_name' do
    context 'with invalid name' do
      let(:track) { 'find_by_name/invalid' }

      it 'raises an error' do
        expect { described_class.find_by_name('wayne-corp-realm') }.to raise_error Keycloak::Admin::NotFoundError
      end
    end

    context 'with valid name' do
      let(:track) { 'find_by_name/valid' }

      it 'returns a client' do
        expect(described_class.find_by_name('acme-corp-realm')).to include realm
      end
    end
  end

  describe '#update' do
    let(:name) { described_class.find_by(realm: 'acme-corp-realm').first.realm }

    context 'with invalid attributes' do
      let(:track) { 'update/invalid_attributes' }

      it 'raises an error' do
        expect { described_class.update(name, invalid: true) }.to raise_error Keycloak::Admin::BadRequestError
      end
    end

    context 'with invalid id' do
      let(:track) { 'update/invalid_id' }

      it 'raises an error' do
        expect do
          described_class.update('wayne-corp-realm', displayName: 'Acme Corp')
        end.to raise_error Keycloak::Admin::NotFoundError
      end
    end

    context 'with valid attributes' do
      let(:track) { 'update/valid' }

      it 'updates a group' do
        expect(described_class.update(name, displayName: 'Acme Corp')).to be_nil
      end
    end
  end

  describe '#delete' do
    context 'with invalid id' do
      let(:track) { 'delete/invalid' }

      it 'raises an error' do
        expect { described_class.delete('wayne-corp-realm') }.to raise_error Keycloak::Admin::NotFoundError
      end
    end

    context 'with valid id' do
      let(:track) { 'delete/valid' }

      it 'deletes a client' do
        expect(described_class.delete('acme-corp-realm')).to be_nil
      end
    end
  end

  describe '#all' do
    let(:track) { 'all' }

    it 'returns a list containing one realm', :aggregate_failures do
      all = described_class.all
      expect(all).to be_an Array
      expect(all.count).to be 1
      expect(all.first.realm).to eq 'master'
    end
  end
end
