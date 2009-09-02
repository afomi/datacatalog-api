module DataCatalog

  class Organizations < Base
  
    restful_routes do
      name "organizations"
      model Organization, :read_only => [
        :user_id,
        :needs_curation,
        :created_at,
        :updated_at
      ]
    end

  end

end
