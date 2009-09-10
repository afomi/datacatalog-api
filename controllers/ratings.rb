module DataCatalog

  class Ratings < Base

    restful_routes do
      name "ratings"
      model Rating, :read_only => [
        :previous_value,
        :user_id,
        :created_at,
        :updated_at
      ]
      callback :before_create do
        params["user_id"] = @current_user.id
      end
    end

  end

end
