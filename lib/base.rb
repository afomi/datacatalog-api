gem 'rest-sinatra', '>= 0.3.3', '< 0.4.0'
require 'rest-sinatra'

module DataCatalog
  
  class Base < Sinatra::Base

    include RestSinatra
    
    before do
      content_type :json
    end

  end
  
end
