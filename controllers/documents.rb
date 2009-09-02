module DataCatalog
  
  class Documents < Base

    restful_routes do
      name "documents"
      model Document, :read_only => [
        :created_at,
        :updated_at
      ]
    end

  end

end
