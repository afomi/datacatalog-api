module DataCatalog
  
  class Comments < Base
    
    restful_routes do
      name "comments"
      model Comment, :read_only => [
        :created_at,
        :updated_at
      ]
      callback :before_create do
        params["user_id"] = @current_user.id
      end
    end

  end

end
