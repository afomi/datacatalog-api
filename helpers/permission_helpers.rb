module DataCatalog

  module PermissionHelpers

    def permission_check(default_level, custom_level, user_id)
      if custom_level && custom_level == :owner
        require_at_least custom_level, user_id
      elsif custom_level
        require_at_least custom_level
      else
        require_at_least default_level
      end
    end

    def require_at_least(level, user_id=nil)
      @privileges = privileges_for_api_key(user_id)
      case level
      when :basic
        missing_api_key! if @privileges[:anonymous]
        invalid_api_key! unless @privileges[:basic]
      when :owner
        missing_api_key! if @privileges[:anonymous]
        invalid_api_key! unless @privileges[:basic]
        unauthorized_api_key! unless @privileges[:owner]
      when :curator
        missing_api_key! if @privileges[:anonymous]
        invalid_api_key! unless @privileges[:basic]
        unauthorized_api_key! unless @privileges[:curator]
      when :admin
        missing_api_key! if @privileges[:anonymous]
        invalid_api_key! unless @privileges[:basic]
        unauthorized_api_key! unless @privileges[:admin]
      else
        raise "Unexpected parameter"
      end
    end

    def privileges_for_api_key(user_id=nil)
      return @cached_privileges if @cached_privileges
      default = {
        :anonymous => false,
        :basic     => false,
        :owner     => false,
        :curator   => false,
        :admin     => false
      }
      api_key = params.delete("api_key")
      unless api_key
        return default.merge(:anonymous => true)
      end
      @current_user = User.find(:first, :conditions => { 'api_keys.api_key' => api_key })
      unless @current_user
        return default
      end
      if @current_user.admin
        return default.merge(:admin => true, :curator => true, :owner => true, :basic => true)
      end
      if @current_user.curator
        return default.merge(:curator => true, :owner => true, :basic => true)
      end
      if user_id && user_id == @current_user.id
        return default.merge(:owner => true, :basic => true)
      end
      @cached_privileges = default.merge(:basic => true)
    end
    
    protected

    def missing_api_key!
      error 401, { "errors" => ["missing_api_key"] }.to_json
    end

    def invalid_api_key!
      error 401, { "errors" => ["invalid_api_key"] }.to_json
    end

    def unauthorized_api_key!
      error 401, { "errors" => ["unauthorized_api_key"] }.to_json
    end

  end

  class Base
    helpers PermissionHelpers
  end

end
