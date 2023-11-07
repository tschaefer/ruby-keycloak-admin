# frozen_string_literal: true

require 'spec_helper'

require 'keycloak/admin'

RSpec.describe Keycloak::Admin, order: :defined do # rubocop:disable RSpec/SpecFilePathFormat, RSpec/FilePath
  around do |example|
    if ENV['VCR_OFF']
      example.run
    else
      VCR.use_cassette("admin/#{track}", record: :new_episodes) do
        example.run
      end
    end
  end

  context 'when not configured' do
    let(:track) { 'not_configured' }

    before do
      described_class.reset!
    end

    describe '#configured?' do
      it 'returns false' do
        expect(described_class.configured?).to be false
      end
    end

    describe '#configured!' do
      it 'raises an error' do
        expect { described_class.configured! }.to raise_error Keycloak::Admin::ConfigurationError
      end
    end
  end

  context 'when configured' do
    let(:track) { 'configured' }

    describe '#configure' do
      it 'returns Keycloak::Admin::Manage class' do
        expect(described_class.configure {}).to be true # rubocop:disable Lint/EmptyBlock
      end
    end

    describe '#configured?' do
      it 'returns true' do
        expect(described_class.configured?).to be true
      end
    end

    describe '#configured!' do
      it 'does not raise an error' do
        expect { described_class.configured! }.not_to raise_error
      end
    end
  end

  describe '#reset!' do
    let(:track) { 'reset' }

    it 'clears the configuration' do
      described_class.reset!
      expect(described_class.configured?).to be false
    end
  end
end

module Keycloack
  module Admin
    class Agent
      def logout
        true
      end
    end
  end
end
