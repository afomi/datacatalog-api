gem 'sinatra_resource', '>= 0.2.6', '< 0.3.0'
require 'sinatra_resource'

module DataCatalog
  
  class Base < Sinatra::Base
    before do
      content_type :json
    end
  end
  
end
