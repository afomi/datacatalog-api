module DataCatalog

  class Ratings < Base

    restful_routes do
      name "ratings"
      model Rating, :read_only => [
        :user_id,
        :created_at,
        :updated_at
      ]
    end

  end

end
