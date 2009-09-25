module DataCatalog
  
  class Documents < Base

    resource "documents" do
      model Document
      read_only :created_at
      read_only :updated_at
    end

  end

end
