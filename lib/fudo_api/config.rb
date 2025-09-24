module FudoApi
  class Config
    attr_accessor :session_timeout, :product_creation_delay, :default_credentials
    
    def initialize
      @session_timeout = ENV.fetch('SESSION_TIMEOUT', 3600).to_i # 1 hour
      @product_creation_delay = ENV.fetch('PRODUCT_CREATION_DELAY', 5).to_i # 5 seconds
      @default_credentials = {
        username: ENV.fetch('DEFAULT_USERNAME', 'admin'),
        password: ENV.fetch('DEFAULT_PASSWORD', 'password')
      }
    end
  end
  
  def self.config
    @config ||= Config.new
  end
  
  def self.configure
    yield(config) if block_given?
  end
end
