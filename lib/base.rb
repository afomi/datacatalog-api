gem 'rest-sinatra', '>= 0.4.0', '< 0.5.0'
require 'rest-sinatra'

module DataCatalog
  
  class Base < Sinatra::Base

    include RestSinatra
    
    before do
      content_type :json
    end

  end
  
end
