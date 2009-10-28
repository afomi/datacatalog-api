gem 'rest-sinatra', '>= 0.4.0', '< 0.5.0'
require 'rest-sinatra'

module DataCatalog
  
  class OldBase < Sinatra::Base

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
    
    def self.owner?(current_user, user)
      current_user.admin || current_user == user
    end

  end
  
end