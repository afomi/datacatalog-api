module DataCatalog

  class Notes < OldBase

    resource "notes" do
      model Note

      permission_to_view :basic
      permission_to_modify :basic
      
      read_only :created_at
      read_only :updated_at

      callback :before_create do
        params["user_id"] = @current_user.id
      end
    end

    def self.permit_view?(current_user, note)
      current_user.admin || current_user == note.user
    end
    
    def self.permit_modify?(current_user, note)
      return true if note.nil?
      current_user.admin || current_user == note.user
    end

  end

end
