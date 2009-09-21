module DataCatalog

  module PermissionHelpers

    def permission_check(default_level, custom_level, user_id)
      if custom_level && custom_level == :owner
        require_at_least(custom_level, user_id)
      elsif custom_level
        require_at_least(custom_level)
      else
        require_at_least(default_level)
      end
    end

    def require_at_least(level, user_id=nil)
      privileges = privileges_for_api_key(user_id)
      case level
      when :anonymous
        return if privileges[:anonymous]
        return invalid_api_key! unless privileges[:basic]
      when :basic
        return missing_api_key! if privileges[:anonymous]
        return invalid_api_key! unless privileges[:basic]
      when :owner
        return missing_api_key! if privileges[:anonymous]
        return invalid_api_key! unless privileges[:basic]
        return unauthorized_api_key! unless privileges[:owner]
      when :curator
        return missing_api_key! if privileges[:anonymous]
        return invalid_api_key! unless privileges[:basic]
        return unauthorized_api_key! unless privileges[:curator]
      when :admin
        return missing_api_key! if privileges[:anonymous]
        return invalid_api_key! unless privileges[:basic]
        return unauthorized_api_key! unless privileges[:admin]
      else
        raise "Unexpected parameter"
      end
    end

    def privileges_for_api_key(user_id=nil)
      return @cached_privileges if @cached_privileges
      @cached_privileges = _privileges_for_api_key(user_id)
    end

    def missing_api_key!
      error 401, { "errors" => ["missing_api_key"] }.to_json
    end

    def invalid_api_key!
      error 401, { "errors" => ["invalid_api_key"] }.to_json
    end

    def unauthorized_api_key!
      error 401, { "errors" => ["unauthorized_api_key"] }.to_json
    end
    
    protected
    
    DEFAULT_PRIVILEGES = {
      :admin     => false,
      :curator   => false,
      :owner     => false,
      :basic     => false,
      :anonymous => false
    }
    
    def _privileges_for_api_key(user_id=nil)
      api_key = params.delete("api_key")
      unless api_key
        return DEFAULT_PRIVILEGES.merge(
          :anonymous => true
        )
      end
      @current_user = User.find_by_api_key(api_key)
      unless @current_user
        return DEFAULT_PRIVILEGES
      end
      if @current_user.admin
        return DEFAULT_PRIVILEGES.merge(
          :admin   => true,
          :curator => true,
          :owner   => true,
          :basic   => true
        )
      end
      if @current_user.curator
        return DEFAULT_PRIVILEGES.merge(
          :curator => true,
          :owner   => true,
          :basic   => true
        )
      end
      if user_id && user_id == @current_user.id
        return DEFAULT_PRIVILEGES.merge(
          :owner => true,
          :basic => true
        )
      end
      DEFAULT_PRIVILEGES.merge(:basic => true)
    end

  end

  if const_defined?("Base")
    class Base
      helpers PermissionHelpers
    end
  end

end
