gem 'rest-sinatra', '>= 0.4.0', '< 0.5.0'
require 'rest-sinatra'

module DataCatalog
  
  class Base < Sinatra::Base

    include RestSinatra
    
    before do
      content_type :json
    end

    # By default, there are no document-based access restrictions.
    def self.permit_view?(current_user, model)
      true
    end

    # By default, there are no document-based access restrictions.
    def self.permit_modify?(current_user, model)
      true
    end
    
    # By default, there are no document-based sanitizations
    def self.sanitize(current_user, model)
      model
    end

  end
  
end
