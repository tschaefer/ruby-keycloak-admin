# frozen_string_literal: true

require 'spec_helper'

require 'keycloak/admin'

RSpec.describe 'Scenario Pagination' do # rubocop:disable RSpec/DescribeClass
  def cassette_exist?
    File.exist?(
      File.expand_path(
        "#{File.dirname(__FILE__)}/../vcr/scenario/pagination.yml"
      )
    )
  end

  def vcr_without_cassette(mode)
    VCR.configure { |c| c.allow_http_connections_when_no_cassette = mode }
  end

  def create_users
    250.times.each { |i| Keycloak::Admin.users.create(username: "user-#{i}") }
  end

  def delete_users
    Keycloak::Admin.users.find_by(username: 'user').each do |user|
      Keycloak::Admin.users.delete(user.id)
    end
  end

  before(:all) do # rubocop:disable RSpec/BeforeAfterAll
    Keycloak::Admin.configure do |config|
      config.base_url = ENV.fetch('KEYCLOAK_BASE_URL', 'http://localhost:8080')
      config.realm = ENV.fetch('KEYCLOAK_REALM', 'master')
      config.username = ENV.fetch('KEYCLOAK_USERNAME', 'admin')
      config.password = ENV.fetch('KEYCLOAK_PASSWORD', 'admin')
    end

    if ENV['VCR_OFF']
      create_users
      next
    end

    if ENV['KEYCLOAK_ADMIN_SPEC_RECORD']
      vcr_without_cassette(true)
      create_users
      vcr_without_cassette(false)
      next
    end
  end

  after(:all) do # rubocop:disable RSpec/BeforeAfterAll
    if ENV['VCR_OFF']
      delete_users
      next
    end

    if ENV['KEYCLOAK_ADMIN_SPEC_RECORD']
      vcr_without_cassette(true)
      delete_users
      vcr_without_cassette(false)
      next
    end
  end

  around do |example|
    if ENV['VCR_OFF']
      example.run
    else
      VCR.use_cassette('scenario/pagination', record: :new_episodes) do
        example.run
      end
    end
  end

  it 'returns 251 users' do
    expect(Keycloak::Admin.users.all.count).to eq 251
  end

  it 'returns 3 pages' do
    expect(Keycloak::Admin.users.send(:pages)).to eq 3
  end
end
