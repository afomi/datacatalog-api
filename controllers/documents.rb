module DataCatalog
  
  class Documents < Base

    resource "documents" do
      model Document

      read_only :created_at
      read_only :updated_at

      callback :before_create do
        params["user_id"] = @current_user.id
      end
    end

  end

end
