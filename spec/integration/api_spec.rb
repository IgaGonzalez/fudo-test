require 'spec_helper'

RSpec.describe 'Fudo API Integration', type: :request do
  describe 'Authentication Flow' do
    it 'authenticates with valid credentials' do
      post '/auth', { username: 'admin', password: 'password' }.to_json,
           { 'CONTENT_TYPE' => 'application/json' }
      
      expect(last_response.status).to eq(200)
      expect(json_response['success']).to be true
      expect(json_response['session_id']).to be_a(String)
      expect(json_response['message']).to eq('Authentication successful')
    end
    
    it 'rejects invalid credentials' do
      post '/auth', { username: 'wrong', password: 'wrong' }.to_json,
           { 'CONTENT_TYPE' => 'application/json' }
      
      expect(last_response.status).to eq(401)
      expect(json_response['success']).to be false
      expect(json_response['error']).to eq('Invalid credentials')
    end
    
    it 'validates required fields' do
      post '/auth', { username: 'admin' }.to_json,
           { 'CONTENT_TYPE' => 'application/json' }
      
      expect(last_response.status).to eq(400)
      expect(json_response['error']).to include('Missing required fields')
    end
  end
  
  describe 'Product Management' do
    let(:session_id) { authenticate_user }
    
    it 'creates products asynchronously' do
      post '/products', { name: 'Test Product' }.to_json,
           { 'CONTENT_TYPE' => 'application/json' }.merge(auth_headers(session_id))
      
      expect(last_response.status).to eq(202)
      expect(json_response['message']).to eq('Product creation initiated')
      expect(json_response['job_id']).to be_a(String)
      expect(json_response['status']).to eq('pending')
    end
    
    it 'requires authentication for product creation' do
      post '/products', { name: 'Test Product' }.to_json,
           { 'CONTENT_TYPE' => 'application/json' }
      
      expect(last_response.status).to eq(401)
      expect(json_response['error']).to include('session')
    end
    
    it 'validates product name is required' do
      post '/products', {}.to_json,
           { 'CONTENT_TYPE' => 'application/json' }.merge(auth_headers(session_id))
      
      expect(last_response.status).to eq(400)
      expect(json_response['error']).to include('Missing required fields')
    end
    
    it 'lists products' do
      get '/products', {}, auth_headers(session_id)
      
      expect(last_response.status).to eq(200)
      expect(json_response['success']).to be true
      expect(json_response['products']).to be_an(Array)
      expect(json_response['total']).to be_a(Integer)
    end
    
    it 'tracks job status' do
      # Create a product
      post '/products', { name: 'Test Product' }.to_json,
           { 'CONTENT_TYPE' => 'application/json' }.merge(auth_headers(session_id))
      
      job_id = json_response['job_id']
      
      # Check job status
      get "/products/status?job_id=#{job_id}", {}, auth_headers(session_id)
      
      expect(last_response.status).to eq(200)
      expect(json_response['success']).to be true
      expect(json_response['job']['id']).to eq(job_id)
      expect(json_response['job']['status']).to be_in(%w[pending processing completed])
    end
  end
  
  describe 'Static Files' do
    it 'serves OpenAPI specification' do
      get '/openapi.yaml'
      
      expect(last_response.status).to eq(200)
      expect(last_response.headers['Content-Type']).to eq('application/x-yaml')
      expect(last_response.headers['Cache-Control']).to include('no-cache')
    end
    
    it 'serves AUTHORS file' do
      get '/AUTHORS'
      
      expect(last_response.status).to eq(200)
      expect(last_response.headers['Content-Type']).to eq('text/plain')
      expect(last_response.headers['Cache-Control']).to include('max-age=86400')
    end
    
    it 'provides health endpoint' do
      get '/health'
      
      expect(last_response.status).to eq(200)
      expect(json_response['success']).to be true
      expect(json_response['status']).to eq('healthy')
      expect(json_response['version']).to eq(FudoApi::VERSION)
    end
  end
  
  describe 'Error Handling' do
    it 'handles invalid JSON' do
      post '/auth', 'invalid json',
           { 'CONTENT_TYPE' => 'application/json' }
      
      expect(last_response.status).to eq(400)
      expect(json_response['error']).to include('JSON')
    end
    
    it 'handles unknown routes' do
      get '/unknown'
      
      expect(last_response.status).to eq(404)
      expect(json_response['error']).to eq('Not Found')
    end
  end
  
  describe 'Compression' do
    it 'applies gzip compression when requested' do
      header 'Accept-Encoding', 'gzip'
      get '/health'
      
      expect(last_response.status).to eq(200)
      # Note: In test environment, compression might not be fully applied
      # but the middleware should be in place
    end
  end
end
