require 'rack'
require 'json'
require_relative 'config'
require_relative 'router'
require_relative 'models/product'
require_relative 'models/session'
require_relative 'models/job'
require_relative 'services/auth_service'
require_relative 'services/product_service'
require_relative 'controllers/auth_controller'
require_relative 'controllers/products_controller'
require_relative 'controllers/static_controller'
require_relative 'middleware/auth_middleware'
require_relative 'middleware/error_handler'

module FudoApi
  class Application
    def initialize
      # Initialize repositories
      @product_repository = Models::ProductRepository.new
      @session_repository = Models::SessionRepository.new
      @job_repository = Models::JobRepository.new
      
      # Initialize services
      @auth_service = Services::AuthService.new(@session_repository)
      @product_service = Services::ProductService.new(@product_repository, @job_repository)
      
      # Build middleware stack
      @app = build_middleware_stack
    end
    
    def call(env)
      @app.call(env)
    end
    
    private
    
    def build_middleware_stack
      # Store self reference for the builder
      app_instance = self
      
      # Build the middleware stack
      Rack::Builder.new do
        # Error handling (outermost)
        use FudoApi::Middleware::ErrorHandler
        
        # Gzip compression
        use Rack::Deflater
        
        # Authentication middleware
        use FudoApi::Middleware::AuthMiddleware, app_instance.instance_variable_get(:@auth_service)
        
        # Main application
        run app_instance.method(:dispatch)
      end
    end
    
    def dispatch(env)
      request = Rack::Request.new(env)
      
      # Match route
      route_match = Router.match(request.request_method, request.path_info)
      
      return not_found_response unless route_match
      
      # Extract controller and action from route
      action_name = route_match[:action]
      controller_name, method_name = action_name.to_s.split('_', 2)
      
      # Route to appropriate controller
      case controller_name
      when 'auth'
        controller = Controllers::AuthController.new(request, env, @auth_service)
      when 'products'
        controller = Controllers::ProductsController.new(request, env, @product_service)
      when 'static'
        controller = Controllers::StaticController.new(request, env)
      else
        return not_found_response
      end
      
      # Call controller method
      if controller.respond_to?(method_name)
        controller.public_send(method_name)
      else
        not_found_response
      end
    end
    
    def not_found_response
      [404, { 'Content-Type' => 'application/json' }, 
       [{ error: 'Not Found', success: false }.to_json]]
    end
  end
end
