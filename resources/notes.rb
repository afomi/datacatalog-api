module DataCatalog

  class Notes < Base
    include Resource

    model Note

    # == Permissions

    roles Roles
    permission :list   => :basic
    permission :read   => :owner
    permission :create => :basic
    permission :update => :owner
    permission :delete => :owner

    # == Properties

    property :text
    property :source_id
    property :user_id,  :w => :nobody

    # == Callbacks

    callback :before_create do |action|
      raise "expecting current_user" unless action.current_user
      action.params["user_id"] = action.current_user.id
    end

  end

  Notes.build

end
