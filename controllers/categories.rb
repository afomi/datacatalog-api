module DataCatalog

  class Categories < Base
    
    resource "categories" do
      model Category
      read_only :created_at
      read_only :updated_at
    end

  end

end
