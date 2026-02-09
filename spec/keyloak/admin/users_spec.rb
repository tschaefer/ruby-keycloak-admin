# frozen_string_literal: true

require 'spec_helper'

require 'keycloak/admin/agent'
require 'keycloak/admin/users'

RSpec.describe Keycloak::Admin::Users, order: :defined do # rubocop:disable RSpec/SpecFilePathFormat
  before(:all) do # rubocop:disable RSpec/BeforeAfterAll
    agent = Keycloak::Admin::Agent.new
    agent.base_url = 'http://localhost:8080'
    agent.realm = 'master'
    agent.username = 'admin'
    agent.password = 'admin'

    described_class.agent = agent
  end

  let(:user) do
    {
      'username' => 'john.doe',
      'firstName' => 'John',
      'lastName' => 'Doe',
      'email' => 'john.doe@acme.corp'
    }
  end

  around do |example|
    if ENV['VCR_OFF']
      example.run
    else
      VCR.use_cassette("users/#{track}", record: :new_episodes) do
        example.run
      end
    end
  end

  describe '#create' do
    context 'with invalid attributes' do
      let(:track) { 'create/invalid' }

      it 'raises an error' do
        expect do
          described_class.create(username: 'john.doe', invalid: true)
        end.to raise_error Keycloak::Admin::BadRequestError
      end
    end

    context 'when user already exists' do
      let(:track) { 'create/exists' }

      it 'raises an error' do
        expect do
          described_class.create(username: 'admin')
        end.to raise_error Keycloak::Admin::ConflictError
      end
    end

    context 'with valid attributes' do
      let(:track) { 'create/valid' }

      it 'creates a user' do
        expect(described_class.create(user)).to be_nil
      end
    end
  end

  describe '#find_by', :aggregate_failures do
    context 'with invalid attributes' do
      let(:track) { 'find_by/invalid' }

      it 'returns empty list' do
        result = described_class.find_by(invalid: true)
        expect(result).to be_an(Array)
        expect(result.empty?).to be true
      end
    end

    context 'with valid attributes' do
      let(:track) { 'find_by/valid' }

      it 'returns list of users' do # rubocop:disable RSpec/ExampleLength
        result = described_class.find_by(firstName: 'John')
        expect(result).to be_an(Array)
        expect(result.size).to be 1
        hash = result.first
        user.each do |key, value|
          expect(hash[key]).to eq value
        end
      end
    end
  end

  describe '#update' do
    let(:id) { described_class.find_by(username: 'john.doe').first['id'] }

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

      it 'updates a user' do
        expect(described_class.update(id, emailVerified: true)).to be_nil
      end
    end
  end

  describe '#delete' do
    let(:id) { described_class.find_by(username: 'john.doe').first['id'] }

    context 'with invalid id' do
      let(:track) { 'delete/invalid' }

      it 'raises an error' do
        expect { described_class.delete('47110815-42gg') }.to raise_error Keycloak::Admin::NotFoundError
      end
    end

    context 'with valid id' do
      let(:track) { 'delete/valid' }

      it 'deletes a user' do
        expect(described_class.delete(id)).to be_nil
      end
    end
  end

  describe '#all' do
    let(:track) { 'all' }

    it 'returns list of all users', :aggregate_failures do
      all = described_class.all
      expect(all).to be_an Array
      expect(all.size).to eq 1
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
      let(:id) { described_class.all.first['id'] }

      it 'returns a user' do
        expect(described_class.find_by_id(id)).to include username: 'admin'
      end
    end
  end

  describe '#password' do
    around do |example|
      described_class.create(user)
      example.run
      described_class.delete(described_class.find_by(username: 'john.doe').first['id'])
    end

    context 'with empty password' do
      let(:track) { 'password/empty' }

      it 'raises an error' do
        id = described_class.find_by(username: 'john.doe').first['id']

        attributes = {
          type: 'password',
          temporary: false,
          value: ''
        }
        expect { described_class.password(id, attributes) }.to raise_error Keycloak::Admin::BadRequestError
      end
    end

    context 'with valid password' do
      let(:track) { 'password/valid' }

      it 'creates a password credential' do
        id = described_class.find_by(username: 'john.doe').first['id']

        attributes = {
          type: 'password',
          temporary: false,
          value: 'qwe123$!'
        }
        expect { described_class.password(id, attributes) }.not_to raise_error
      end
    end
  end
end
