require_relative 'base_controller'

module FudoApi
  module Controllers
    class AuthController < BaseController
      def initialize(request, env, auth_service)
        super(request, env)
        @auth_service = auth_service
      end
      
      def login
        data = parse_json_body
        validate_required_params(data, :username, :password)
        
        result = @auth_service.authenticate(
          username: data['username'],
          password: data['password']
        )
        
        if result[:success]
          success_response({
            message: 'Authentication successful',
            session_id: result[:session].id,
            expires_at: (result[:session].created_at + FudoApi.config.session_timeout).iso8601
          })
        else
          error_response(result[:error], 401)
        end
      rescue ArgumentError => e
        bad_request(e.message)
      rescue JSON::ParserError => e
        bad_request('Invalid JSON format')
      end
    end
  end
end
