require 'spec_helper'

RSpec.describe FudoApi::Models::Product do
  describe '#initialize' do
    it 'creates a product with id and name' do
      product = described_class.new(id: 1, name: 'Test Product')
      
      expect(product.id).to eq(1)
      expect(product.name).to eq('Test Product')
      expect(product.created_at).to be_a(Time)
    end
    
    it 'accepts custom created_at time' do
      custom_time = Time.now - 3600
      product = described_class.new(id: 1, name: 'Test', created_at: custom_time)
      
      expect(product.created_at).to eq(custom_time)
    end
  end
  
  describe '#to_h' do
    it 'returns hash representation' do
      product = described_class.new(id: 1, name: 'Test Product')
      hash = product.to_h
      
      expect(hash).to include(
        id: 1,
        name: 'Test Product',
        created_at: product.created_at.iso8601
      )
    end
  end
end

RSpec.describe FudoApi::Models::ProductRepository do
  let(:repository) { described_class.new }
  
  describe '#create' do
    it 'creates a product with incremental ID' do
      product1 = repository.create(name: 'Product 1')
      product2 = repository.create(name: 'Product 2')
      
      expect(product1.id).to eq(1)
      expect(product2.id).to eq(2)
      expect(product1.name).to eq('Product 1')
      expect(product2.name).to eq('Product 2')
    end
  end
  
  describe '#find_by_id' do
    it 'finds existing product' do
      created_product = repository.create(name: 'Test Product')
      found_product = repository.find_by_id(created_product.id)
      
      expect(found_product).to eq(created_product)
    end
    
    it 'returns nil for non-existent product' do
      expect(repository.find_by_id(999)).to be_nil
    end
  end
  
  describe '#all' do
    it 'returns all products' do
      repository.create(name: 'Product 1')
      repository.create(name: 'Product 2')
      
      all_products = repository.all
      expect(all_products).to have(2).items
      expect(all_products.map(&:name)).to contain_exactly('Product 1', 'Product 2')
    end
  end
  
  describe '#count' do
    it 'returns correct count' do
      expect(repository.count).to eq(0)
      
      repository.create(name: 'Product 1')
      expect(repository.count).to eq(1)
      
      repository.create(name: 'Product 2')
      expect(repository.count).to eq(2)
    end
  end
end
