module DataCatalog

  class Ratings < Base
    include Resource

    model Rating

    # == Permissions

    roles Roles
    permission :list   => :basic
    permission :read   => :owner
    permission :create => :basic
    permission :update => :owner
    permission :delete => :owner

    # == Properties

    property :kind
    property :user_id,        :w => :nobody
    property :source_id
    property :comment_id
    property :value
    property :previous_value, :w => :nobody
    property :text

    # == Callbacks

    callback :before_create do |action|
      raise "expecting current_user" unless action.current_user
      action.params["user_id"] = action.current_user.id
    end
  end

  Ratings.build

end
