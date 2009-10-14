module DataCatalog

  class Tags < Base

    resource "tags" do
      model Tag

      permission_to_view :basic
      permission_to_modify :curator

      read_only :created_at
      read_only :updated_at
    end

  end

end
