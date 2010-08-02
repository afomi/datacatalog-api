gem 'sinatra_resource', '>= 0.4.20', '< 0.5'
require 'sinatra_resource'

module DataCatalog

  class Base < Sinatra::Base

    before do
      content_type :json
    end

  end

end
