module DataCatalog

  class Sources < Base
  
    restful_routes do
      name "sources"
      model Source, :read_only => [
        :created_at,
        :updated_at
      ]
    end

  end

end
