require 'json'

module FudoApi
  module Controllers
    class BaseController
      def initialize(request, env = {})
        @request = request
        @env = env
      end
      
      protected
      
      def current_session
        @env['fudo_api.session']
      end
      
      def json_response(data, status = 200, headers = {})
        default_headers = { 'Content-Type' => 'application/json' }
        [status, default_headers.merge(headers), [data.to_json]]
      end
      
      def success_response(data = {}, status = 200)
        json_response(data.merge(success: true), status)
      end
      
      def error_response(message, status = 400, code = nil)
        error_data = { error: message, success: false }
        error_data[:code] = code if code
        json_response(error_data, status)
      end
      
      def bad_request(message = 'Bad Request')
        error_response(message, 400)
      end
      
      def not_found(message = 'Not Found')
        error_response(message, 404)
      end
      
      def internal_error(message = 'Internal Server Error')
        error_response(message, 500)
      end
      
      def parse_json_body
        body = @request.body.read
        return {} if body.empty?
        
        JSON.parse(body)
      rescue JSON::ParserError
        raise JSON::ParserError, 'Invalid JSON format'
      end
      
      def validate_required_params(data, *required_fields)
        missing_fields = required_fields.select { |field| data[field.to_s].nil? || data[field.to_s].to_s.strip.empty? }
        
        unless missing_fields.empty?
          field_list = missing_fields.map { |f| "'#{f}'" }.join(', ')
          raise ArgumentError, "Missing required fields: #{field_list}"
        end
      end
    end
  end
end
