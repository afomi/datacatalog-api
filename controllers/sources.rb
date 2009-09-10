module DataCatalog

  class Sources < Base
  
    restful_routes do
      name "sources"
      model Source, :read_only => [
        :ratings_total,
        :ratings_count,
        :created_at,
        :updated_at
      ]
    end

  end

end
