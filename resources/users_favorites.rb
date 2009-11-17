require File.dirname(__FILE__) + '/users'

module DataCatalog

  class UsersFavorites < Base
    include Resource

    parent Users
    child_association :favorites
    model Favorite
    path 'favorites'

    # == Permissions

    roles Roles
    permission :list   => :basic
    permission :read   => :owner
    permission :create => :basic
    permission :update => :owner
    permission :delete => :owner
    
    # == Properties
    
    property :source_id
    
    property :source do |favorite|
      {
        "href"  => "/sources/#{favorite.source_id}",
        "title" => favorite.source.title,
      }
    end
    
    # == Callbacks

    callback :before_create do |action, user|
      # puts "user.id : #{user.id}"
      # puts "action.current_user.id : #{action.current_user.id}"
      unless user.id == action.current_user.id
        action.error(401, action.convert({
          'errors' => ['unauthorized_api_key']
        }))
      end
      action.params["user_id"] = action.current_user.id
    end
    
  end
  
  UsersFavorites.build

end
