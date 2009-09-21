module DataCatalog

  class Categories < Base
  
    restful_routes do
      name "categories"
      model Category, :read_only => [
        :created_at,
        :updated_at
      ]
    end

  end

end
