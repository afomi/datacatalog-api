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
    property :parent_id
    property :jurisdiction_id
    property :slug
    property :url
    property :interest
    property :source_count
    property :custom
    property :raw,              :w => :admin
    property :user_id,          :w => :nobody
    
    property :jurisdiction do |org|
      if org.jurisdiction_id
        jurisdiction = org.jurisdiction
        {
          "name" => jurisdiction.name,
          "href" => "/jurisdictions/#{jurisdiction.id}",
          "slug" => jurisdiction.slug,          
        }
      end
    end
    
    property :parent do |org|
      if org.parent_id
        parent = org.parent
        {
          "name" => parent.name,
          "href" => "/organizations/#{parent.id}",
        }
      end
    end
    
    property :children do |org|
      org.children.map do |child|
        {
          "name" => child.name,
          "href" => "/organizations/#{child.id}",
        }
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
