require 'json'

module FudoApi
  module Middleware
    class ErrorHandler
      def initialize(app)
        @app = app
      end
      
      def call(env)
        @app.call(env)
      rescue JSON::ParserError => e
        bad_request_response('Invalid JSON format')
      rescue => e
        # Log error in production you'd use a proper logger
        puts "ERROR: #{e.class}: #{e.message}"
        puts e.backtrace.join("\n") if ENV['RACK_ENV'] == 'development'
        
        internal_error_response
      end
      
      private
      
      def bad_request_response(message)
        [
          400,
          { 'Content-Type' => 'application/json' },
          [{ error: message }.to_json]
        ]
      end
      
      def internal_error_response
        message = ENV['RACK_ENV'] == 'development' ? 
                    'Internal server error - check logs for details' : 
                    'Internal server error'
        
        [
          500,
          { 'Content-Type' => 'application/json' },
          [{ error: message }.to_json]
        ]
      end
    end
  end
end
