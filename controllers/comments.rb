module DataCatalog
  
  class Comments < OldBase
    
    resource "comments" do
      model Comment

      permission_to_view :basic
      permission_to_modify :curator

      read_only :rating_stats
      read_only :created_at
      read_only :updated_at

      callback :before_create do
        params["user_id"] = @current_user.id
      end
    end

  end

end
