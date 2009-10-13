module DataCatalog

  class Organizations < Base
  
    resource "organizations" do
      model Organization

      read_only :user_id
      read_only :needs_curation
      read_only :created_at
      read_only :updated_at
    end

  end

end
