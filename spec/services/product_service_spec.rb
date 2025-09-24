require 'spec_helper'

RSpec.describe FudoApi::Services::ProductService do
  let(:product_repository) { FudoApi::Models::ProductRepository.new }
  let(:job_repository) { FudoApi::Models::JobRepository.new }
  let(:service) { described_class.new(product_repository, job_repository) }
  
  describe '#create_async' do
    it 'creates a job for async product creation' do
      result = service.create_async(name: 'Test Product')
      
      expect(result[:success]).to be true
      expect(result[:job]).to be_a(FudoApi::Models::Job)
      expect(result[:job].product_name).to eq('Test Product')
      expect(result[:job].status).to eq('pending')
    end
    
    it 'validates product name presence' do
      result = service.create_async(name: '')
      
      expect(result[:success]).to be false
      expect(result[:error]).to eq('Product name is required')
    end
    
    it 'validates product name length' do
      long_name = 'a' * 256
      result = service.create_async(name: long_name)
      
      expect(result[:success]).to be false
      expect(result[:error]).to eq('Product name too long')
    end
    
    it 'trims whitespace from product name' do
      result = service.create_async(name: '  Test Product  ')
      
      expect(result[:success]).to be true
      expect(result[:job].product_name).to eq('Test Product')
    end
  end
  
  describe '#list_all' do
    it 'returns all products sorted by creation time' do
      # Create some products directly in repository
      product1 = product_repository.create(name: 'Product 1')
      sleep(0.01) # Ensure different timestamps
      product2 = product_repository.create(name: 'Product 2')
      
      result = service.list_all
      
      expect(result[:success]).to be true
      expect(result[:products]).to have(2).items
      expect(result[:products].first.id).to eq(product1.id)
      expect(result[:products].last.id).to eq(product2.id)
    end
    
    it 'returns empty array when no products exist' do
      result = service.list_all
      
      expect(result[:success]).to be true
      expect(result[:products]).to be_empty
    end
  end
  
  describe '#find_by_id' do
    it 'finds existing product' do
      product = product_repository.create(name: 'Test Product')
      result = service.find_by_id(product.id)
      
      expect(result[:success]).to be true
      expect(result[:product]).to eq(product)
    end
    
    it 'returns error for non-existent product' do
      result = service.find_by_id(999)
      
      expect(result[:success]).to be false
      expect(result[:error]).to eq('Product not found')
    end
  end
  
  describe '#get_job_status' do
    it 'returns job status' do
      job = job_repository.create(product_name: 'Test Product')
      result = service.get_job_status(job.id)
      
      expect(result[:success]).to be true
      expect(result[:job]).to eq(job)
    end
    
    it 'returns error for non-existent job' do
      result = service.get_job_status('non-existent')
      
      expect(result[:success]).to be false
      expect(result[:error]).to eq('Job not found')
    end
  end
  
  describe '#stats' do
    it 'returns system statistics' do
      # Create some test data
      product_repository.create(name: 'Product 1')
      job1 = job_repository.create(product_name: 'Product 2')
      job2 = job_repository.create(product_name: 'Product 3')
      job2.complete!(product_id: 2)
      job_repository.update(job2)
      
      stats = service.stats
      
      expect(stats[:total_products]).to eq(1)
      expect(stats[:pending_jobs]).to eq(1)
      expect(stats[:completed_jobs]).to eq(1)
      expect(stats[:failed_jobs]).to eq(0)
    end
  end
end
