require 'rack/test'
require 'rspec'
require 'json'
require 'simplecov'

# Start SimpleCov for test coverage
SimpleCov.start do
  add_filter '/spec/'
  add_filter '/vendor/'
end

# Load the application
require_relative '../lib/fudo_api'

RSpec.configure do |config|
  config.include Rack::Test::Methods
  
  # Use expect syntax
  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
  end
  
  # Mock framework
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  
  # Shared context for API testing
  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = "spec/examples.txt"
  config.disable_monkey_patching!
  config.warnings = true
  
  if config.files_to_run.one?
    config.default_formatter = "doc"
  end
  
  config.profile_examples = 10
  config.order = :random
  Kernel.srand config.seed
end

# Helper methods for tests
def app
  FudoApi::Application.new
end

def json_response
  JSON.parse(last_response.body)
end

def authenticate_user(username: 'admin', password: 'password')
  post '/auth', { username: username, password: password }.to_json,
       { 'CONTENT_TYPE' => 'application/json' }
  
  expect(last_response.status).to eq(200)
  json_response['session_id']
end

def auth_headers(session_id)
  { 'HTTP_AUTHORIZATION' => "Bearer #{session_id}" }
end
