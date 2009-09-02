module DataCatalog
  
  class Comments < Base
    
    restful_routes do
      name "comments"
      model Comment, :read_only => [
        :created_at,
        :updated_at
      ]
    end

  end

end
