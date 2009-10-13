module DataCatalog

  class Notes < Base

    resource "notes" do
      model Note

      read_only :created_at
      read_only :updated_at

      callback :before_create do
        params["user_id"] = @current_user.id
      end
    end

  end

end
