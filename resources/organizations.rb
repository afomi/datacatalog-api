module DataCatalog

  class Organizations < Base
    include Resource

    model Organization

    # == Permissions

    roles Roles
    permission :list   => :basic
    permission :read   => :basic
    permission :create => :curator
    permission :update => :curator
    permission :delete => :curator

    # == Properties
    
    property :name
    property :names
    property :acronym
    property :org_type
    property :description
    property :slug
    property :url
    property :interest
    property :level
    property :source_count
    property :custom
    property :raw,              :w => :admin
    property :user_id,          :w => :nobody
    property :jurisdiction_id
    
    property :jurisdiction do |org|
      if org.jurisdiction_id
        {
          "href" => "/jurisdictions/#{org.jurisdiction_id}",
          "name" => org.jurisdiction.name,
          "slug" => org.jurisdiction.slug,          
        }
      else
        nil
      end
    end

    # == Callbacks

    callback :before_create do |action|
      raise "expecting current_user" unless action.current_user
      action.params["user_id"] = action.current_user.id
    end

  end

  Organizations.build

end
