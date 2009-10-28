module DataCatalog

  class Categories < OldBase
    
    resource "categories" do
      model Category

      permission_to_view :basic
      permission_to_modify :curator

      read_only :source_ids
      read_only :created_at
      read_only :updated_at
    end

  end

end
