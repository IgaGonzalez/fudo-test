require_relative 'base_controller'

module FudoApi
  module Controllers
    class ProductsController < BaseController
      def initialize(request, env, product_service)
        super(request, env)
        @product_service = product_service
      end
      
      def create
        data = parse_json_body
        validate_required_params(data, :name)
        
        result = @product_service.create_async(name: data['name'])
        
        if result[:success]
          json_response({
            message: 'Product creation initiated',
            job_id: result[:job].id,
            status: result[:job].status,
            estimated_completion: result[:job].estimated_completion.iso8601
          }, 202)
        else
          bad_request(result[:error])
        end
      rescue ArgumentError => e
        bad_request(e.message)
      rescue JSON::ParserError => e
        bad_request('Invalid JSON format')
      end
      
      def index
        result = @product_service.list_all
        
        if result[:success]
          success_response({
            products: result[:products].map(&:to_h),
            total: result[:products].length
          })
        else
          internal_error(result[:error])
        end
      end
      
      def show
        product_id = @request.path_info.split('/').last.to_i
        
        result = @product_service.find_by_id(product_id)
        
        if result[:success]
          success_response({ product: result[:product].to_h })
        else
          not_found(result[:error])
        end
      end
      
      def job_status
        job_id = @request.params['job_id']
        
        return bad_request('job_id parameter is required') unless job_id
        
        result = @product_service.get_job_status(job_id)
        
        if result[:success]
          success_response({ job: result[:job].to_h })
        else
          not_found(result[:error])
        end
      end
      
      def stats
        stats = @product_service.stats
        success_response({ stats: stats })
      end
    end
  end
end
