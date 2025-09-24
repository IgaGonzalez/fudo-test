module FudoApi
  module Middleware
    class AuthMiddleware
      PROTECTED_PATHS = ['/products'].freeze
      
      def initialize(app, auth_service)
        @app = app
        @auth_service = auth_service
      end
      
      def call(env)
        request = Rack::Request.new(env)
        
        # Skip authentication for non-protected paths
        unless requires_auth?(request)
          return @app.call(env)
        end
        
        # Extract session ID from Authorization header or query params
        session_id = extract_session_id(request)
        
        # Validate session
        auth_result = @auth_service.validate_session(session_id)
        
        unless auth_result[:valid]
          return unauthorized_response(auth_result[:error])
        end
        
        # Add session to environment for controllers
        env['fudo_api.session'] = auth_result[:session]
        
        @app.call(env)
      end
      
      private
      
      def requires_auth?(request)
        PROTECTED_PATHS.any? { |path| request.path_info.start_with?(path) }
      end
      
      def extract_session_id(request)
        # Try Authorization header first (Bearer token)
        auth_header = request.get_header('HTTP_AUTHORIZATION')
        if auth_header&.start_with?('Bearer ')
          return auth_header.sub('Bearer ', '')
        end
        
        # Fallback to query parameter
        request.params['session_id']
      end
      
      def unauthorized_response(error_message)
        [
          401,
          { 'Content-Type' => 'application/json' },
          [{ error: error_message }.to_json]
        ]
      end
    end
  end
end
