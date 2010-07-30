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
    property :slug
    property :url
    property :home_url
    property :catalog_name
    property :catalog_url
    property :interest
    property :top_level
    property :source_count
    property :custom
    property :raw,              :w => :admin
    property :user_id,          :w => :nobody
    
    property :parent do |organization|
      if organization.parent_id
        if parent = organization.parent
          {
            "name" => parent.name,
            "href" => "/organizations/#{parent.id}",
            "slug" => parent.slug,
          }
        end
      end
    end

    property :top_parent do |organization|
      if organization.top_parent_id
        if top_parent = organization.top_parent
          {
            "name" => top_parent.name,
            "href" => "/organizations/#{top_parent.id}",
            "slug" => top_parent.slug,
          }
        end
      end
    end

    property :children do |organization|
      organization.children.map do |child|
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
