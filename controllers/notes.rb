module DataCatalog

  class Notes < Base

    resource "notes" do
      model Note

      read_only :created_at
      read_only :updated_at
    end

  end

end
