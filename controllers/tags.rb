module DataCatalog

  class Tags < Base

    restful_routes do
      name "tags"
      model Tag, :read_only => [
        :created_at,
        :updated_at
      ]
    end

  end

end
