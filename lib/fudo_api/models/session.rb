require 'concurrent'
require 'securerandom'

module FudoApi
  module Models
    class Session
      attr_reader :id, :username, :created_at
      
      def initialize(username:)
        @id = SecureRandom.hex(32)
        @username = username
        @created_at = Time.now
      end
      
      def expired?
        Time.now > (@created_at + FudoApi.config.session_timeout)
      end
      
      def valid?
        !expired?
      end
      
      def to_h
        {
          id: @id,
          username: @username,
          created_at: @created_at.iso8601,
          expires_at: (@created_at + FudoApi.config.session_timeout).iso8601
        }
      end
    end
    
    class SessionRepository
      def initialize
        @sessions = Concurrent::Hash.new
      end
      
      def create(username:)
        session = Session.new(username: username)
        @sessions[session.id] = session
        session
      end
      
      def find_by_id(id)
        session = @sessions[id]
        return nil unless session
        
        if session.expired?
          delete(id)
          return nil
        end
        
        session
      end
      
      def delete(id)
        @sessions.delete(id)
      end
      
      def cleanup_expired!
        @sessions.each do |id, session|
          delete(id) if session.expired?
        end
      end
    end
  end
end
