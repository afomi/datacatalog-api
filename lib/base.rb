module DataCatalog
  
  class Base < Sinatra::Base

    include RestSinatra
    
    before do
      content_type :json
    end

  end
  
end
