module DataCatalog

  class Ratings < Base

    resource "ratings" do
      model Rating
      read_only :previous_value
      read_only :user_id
      read_only :created_at
      read_only :updated_at

      callback :before_create do
        params["user_id"] = @current_user.id
      end
    end

  end

end
