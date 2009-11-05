module DataCatalog

  class Favorites < Base
    include Resource

    model Favorite

    # == Permissions

    roles Roles
    permission :list   => :basic
    permission :read   => :owner
    permission :create => :basic
    permission :update => :owner
    permission :delete => :owner

    # == Properties

    property :source_id
    property :user_id, :w => :nobody
    
    property :source do |favorite|
      {
        "href"  => "/sources/#{favorite.source_id}",
        "title" => favorite.source.title,
      }
    end
    
    property :user do |favorite|
      {
        "href" => "/users/#{favorite.user_id}",
        "name" => favorite.user.name,
      }
    end

    # == Callbacks

    callback :before_create do |action|
      raise "expecting current_user" unless action.current_user
      action.params["user_id"] = action.current_user.id
    end

  end
  
  Favorites.build

end
