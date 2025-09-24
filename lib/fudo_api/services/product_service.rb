require 'concurrent'

module FudoApi
  module Services
    class ProductService
      def initialize(product_repository, job_repository)
        @product_repository = product_repository
        @job_repository = job_repository
        @executor = Concurrent::Promises.default_executor
      end
      
      def create_async(name:)
        # Validate product name
        return { success: false, error: 'Product name is required' } if name.nil? || name.strip.empty?
        return { success: false, error: 'Product name too long' } if name.length > 255
        
        # Create job
        job = @job_repository.create(product_name: name.strip)
        
        # Schedule async product creation
        Concurrent::Promises.schedule(FudoApi.config.product_creation_delay) do
          begin
            job.start_processing!
            @job_repository.update(job)
            
            product = @product_repository.create(name: job.product_name)
            job.complete!(product_id: product.id)
            @job_repository.update(job)
          rescue => e
            job.fail!("Failed to create product: #{e.message}")
            @job_repository.update(job)
          end
        end
        
        { success: true, job: job }
      end
      
      def list_all
        products = @product_repository.all.sort_by(&:created_at)
        { success: true, products: products }
      end
      
      def find_by_id(id)
        product = @product_repository.find_by_id(id)
        if product
          { success: true, product: product }
        else
          { success: false, error: 'Product not found' }
        end
      end
      
      def get_job_status(job_id)
        job = @job_repository.find_by_id(job_id)
        if job
          { success: true, job: job }
        else
          { success: false, error: 'Job not found' }
        end
      end
      
      def stats
        {
          total_products: @product_repository.count,
          pending_jobs: @job_repository.all.count { |job| job.pending? || job.processing? },
          completed_jobs: @job_repository.all.count(&:completed?),
          failed_jobs: @job_repository.all.count(&:failed?)
        }
      end
    end
  end
end
