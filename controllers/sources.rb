module DataCatalog

  class Sources < Base
  
    resource "sources" do
      model Source
      read_only :ratings_total
      read_only :ratings_count
      read_only :created_at
      read_only :updated_at
    end

  end

end
