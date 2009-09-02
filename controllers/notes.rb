module DataCatalog

  class Notes < Base

    restful_routes do
      name "notes"
      model Note, :read_only => [
        :created_at,
        :updated_at
      ]
    end

  end

end
