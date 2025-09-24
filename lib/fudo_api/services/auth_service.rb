module FudoApi
  module Services
    class AuthService
      def initialize(session_repository)
        @session_repository = session_repository
      end
      
      def authenticate(username:, password:)
        config = FudoApi.config
        
        if username == config.default_credentials[:username] && 
           password == config.default_credentials[:password]
          session = @session_repository.create(username: username)
          { success: true, session: session }
        else
          { success: false, error: 'Invalid credentials' }
        end
      end
      
      def validate_session(session_id)
        return { valid: false, error: 'No session ID provided' } unless session_id
        
        session = @session_repository.find_by_id(session_id)
        
        if session&.valid?
          { valid: true, session: session }
        else
          { valid: false, error: 'Invalid or expired session' }
        end
      end
    end
  end
end
