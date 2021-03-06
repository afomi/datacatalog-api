module DataCatalog

  class Comments < Base
    include Resource

    model Comment

    # == Permissions

    roles Roles
    permission :list   => :basic
    permission :read   => :basic
    permission :create => :basic
    permission :update => :owner
    permission :delete => :owner

    # == Properties

    property :text
    property :reports_problem
    property :source_id
    property :parent_id
    property :user_id,      :w => :nobody
    property :rating_stats, :w => :nobody

    # == Callbacks

    callback :before_create do |action|
      raise "expecting current_user" unless action.current_user
      action.params["user_id"] = action.current_user.id
    end

  end

  Comments.build

end
