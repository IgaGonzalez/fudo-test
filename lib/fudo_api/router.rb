module FudoApi
  class Router
    ROUTES = {
      ['POST', '/auth'] => :auth_login,
      ['GET', '/products'] => :products_index,
      ['POST', '/products'] => :products_create,
      ['GET', '/products/status'] => :products_job_status,
      ['GET', '/products/stats'] => :products_stats,
      ['GET', %r{^/products/(\d+)$}] => :products_show,
      ['GET', '/openapi.yaml'] => :static_openapi,
      ['GET', '/AUTHORS'] => :static_authors,
      ['GET', '/health'] => :static_health
    }.freeze
    
    def self.match(method, path)
      ROUTES.each do |(route_method, route_path), action|
        next unless method == route_method
        
        if route_path.is_a?(String)
          return { action: action, params: {} } if path == route_path
        elsif route_path.is_a?(Regexp)
          match_data = path.match(route_path)
          return { action: action, params: { id: match_data[1] } } if match_data
        end
      end
      
      nil
    end
  end
end
