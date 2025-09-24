require 'concurrent'

module FudoApi
  module Models
    class Product
      attr_reader :id, :name, :created_at
      
      def initialize(id:, name:, created_at: Time.now)
        @id = id
        @name = name
        @created_at = created_at
      end
      
      def to_h
        {
          id: @id,
          name: @name,
          created_at: @created_at.iso8601
        }
      end
      
      def to_json(*args)
        to_h.to_json(*args)
      end
    end
    
    class ProductRepository
      def initialize
        @products = Concurrent::Hash.new
        @counter = Concurrent::AtomicFixnum.new(0)
      end
      
      def create(name:)
        id = @counter.increment
        product = Product.new(id: id, name: name)
        @products[id] = product
        product
      end
      
      def find_by_id(id)
        @products[id]
      end
      
      def all
        @products.values
      end
      
      def count
        @products.size
      end
    end
  end
end
