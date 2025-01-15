# frozen_string_literal: true

require 'spec_helper'

require 'keycloak/admin'

RSpec.describe Keycloak::Admin, order: :defined do # rubocop:disable RSpec/SpecFilePathFormat
  context 'when not configured' do
    before do
      allow_any_instance_of(Keycloak::Admin::Agent).to receive(:logout).and_return(true)
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
    before do
      allow_any_instance_of(Keycloak::Admin::Agent).to receive(:logout).and_return(true)
      described_class.reset!
      described_class.configure {} # rubocop:disable Lint/EmptyBlock
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
    it 'clears the configuration' do
      described_class.reset!
      expect(described_class.configured?).to be false
    end
  end

  describe '#ready?' do
    context 'when not configured' do
      before do
        allow_any_instance_of(Keycloak::Admin::Agent).to receive(:logout).and_return(true)
        described_class.reset!
      end

      it 'raises an error' do
        expect { described_class.ready? }.to raise_error Keycloak::Admin::ConfigurationError
      end
    end

    context 'when healthcheck not available' do
      before do
        allow_any_instance_of(Keycloak::Admin::Agent).to receive(:head).and_raise(Keycloak::Admin::NotFoundError)
        described_class.configure {} # rubocop:disable Lint/EmptyBlock
      end

      it 'returns nil' do
        expect(described_class.ready?).to be_nil
      end
    end

    context 'when server is ready' do
      before do
        allow_any_instance_of(Keycloak::Admin::Agent).to receive(:head).and_return(true)
        described_class.configure {} # rubocop:disable Lint/EmptyBlock
      end

      it 'returns true' do
        expect(described_class.ready?).to be true
      end
    end

    context 'when server is not ready' do
      before do
        allow_any_instance_of(Keycloak::Admin::Agent).to receive(:head)
          .and_raise(Keycloak::Admin::ServiceUnavailableError)
        described_class.configure {} # rubocop:disable Lint/EmptyBlock
      end

      it 'returns false' do
        expect(described_class.ready?).to be false
      end
    end
  end
end
