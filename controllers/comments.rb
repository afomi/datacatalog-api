module DataCatalog
  
  class Comments < Base
    
    resource "comments" do
      model Comment

      read_only :rating_stats
      read_only :created_at
      read_only :updated_at

      callback :before_create do
        params["user_id"] = @current_user.id
      end
    end

  end

end
