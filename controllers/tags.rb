module DataCatalog

  class Tags < Base

    resource "tags" do
      model Tag
      read_only :created_at
      read_only :updated_at
    end

  end

end
