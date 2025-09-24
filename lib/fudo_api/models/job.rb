require 'concurrent'
require 'securerandom'

module FudoApi
  module Models
    class Job
      attr_reader :id, :product_id, :product_name, :status, :created_at, :estimated_completion
      
      STATUSES = %w[pending processing completed failed].freeze
      
      def initialize(product_name:)
        @id = SecureRandom.hex(16)
        @product_name = product_name
        @status = 'pending'
        @created_at = Time.now
        @estimated_completion = @created_at + FudoApi.config.product_creation_delay
      end
      
      def start_processing!
        @status = 'processing'
      end
      
      def complete!(product_id:)
        @product_id = product_id
        @status = 'completed'
      end
      
      def fail!(error_message = nil)
        @status = 'failed'
        @error_message = error_message
      end
      
      def completed?
        @status == 'completed'
      end
      
      def failed?
        @status == 'failed'
      end
      
      def pending?
        @status == 'pending'
      end
      
      def processing?
        @status == 'processing'
      end
      
      def to_h
        result = {
          id: @id,
          product_name: @product_name,
          status: @status,
          created_at: @created_at.iso8601,
          estimated_completion: @estimated_completion.iso8601
        }
        
        result[:product_id] = @product_id if @product_id
        result[:error_message] = @error_message if @error_message
        
        result
      end
    end
    
    class JobRepository
      def initialize
        @jobs = Concurrent::Hash.new
      end
      
      def create(product_name:)
        job = Job.new(product_name: product_name)
        @jobs[job.id] = job
        job
      end
      
      def find_by_id(id)
        @jobs[id]
      end
      
      def update(job)
        @jobs[job.id] = job
        job
      end
      
      def all
        @jobs.values
      end
    end
  end
end
