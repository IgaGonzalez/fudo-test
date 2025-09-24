require_relative 'base_controller'

module FudoApi
  module Controllers
    class StaticController < BaseController
      def openapi
        file_path = File.join(File.dirname(__FILE__), '..', '..', '..', 'public', 'openapi.yaml')
        
        if File.exist?(file_path)
          content = File.read(file_path)
          [200, { 
            'Content-Type' => 'application/x-yaml',
            'Cache-Control' => 'no-cache, no-store, must-revalidate',
            'Pragma' => 'no-cache',
            'Expires' => '0'
          }, [content]]
        else
          not_found('OpenAPI specification not found')
        end
      end
      
      def authors
        file_path = File.join(File.dirname(__FILE__), '..', '..', '..', 'public', 'AUTHORS')
        
        if File.exist?(file_path)
          content = File.read(file_path)
          [200, { 
            'Content-Type' => 'text/plain',
            'Cache-Control' => 'public, max-age=86400'  # 24 hours
          }, [content]]
        else
          not_found('AUTHORS file not found')
        end
      end
      
      def health
        success_response({
          status: 'healthy',
          version: FudoApi::VERSION,
          timestamp: Time.now.iso8601
        })
      end
    end
  end
end
