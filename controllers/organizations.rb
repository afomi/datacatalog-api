module DataCatalog

  class Organizations < OldBase
  
    resource "organizations" do
      model Organization

      permission_to_view :basic
      permission_to_modify :curator

      read_only :user_id
      read_only :needs_curation
      read_only :created_at
      read_only :updated_at
    end

  end

end
