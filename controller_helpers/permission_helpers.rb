require File.dirname(__FILE__) + '/status_code_helpers'

module DataCatalog

  module PermissionHelpers

    include StatusCodeHelpers

    def permission_check(args)
      level        = args[:level]
      default      = args[:default]
      override     = args[:override]
      raise "Bad arguments" if level && (default || override)
      minimum_level = level || (override || default)
      verify_permission(minimum_level)
    end
      
    protected

    DEFAULTS = {
      :admin     => false,
      :curator   => false,
      :basic     => false,
      :anonymous => false
    }

    def lookup_privileges
      api_key = params.delete("api_key")
      return DEFAULTS.merge(:anonymous => true) unless api_key
      @current_user = User.find_by_api_key(api_key)
      return DEFAULTS unless @current_user
      lookup_privileges_for_user(@current_user)
    end
    
    def lookup_privileges_for_user(user)
      if user.admin
        DEFAULTS.merge(
          :admin   => true,
          :curator => true,
          :basic   => true
        )
      elsif user.curator
        DEFAULTS.merge(
          :curator => true,
          :basic   => true
        )
      else
        DEFAULTS.merge(
          :basic => true
        )
      end
    end
    
    def privileges
      return @cached_privileges if @cached_privileges
      @cached_privileges = lookup_privileges
    end

    # Verify that a minimum_level of permission exists
    def verify_permission(minimum_level)
      p = privileges
      case minimum_level
      when :anonymous
        return if p[:anonymous]
        invalid_api_key! unless p[:basic]
      when :basic
        missing_api_key! if p[:anonymous]
        invalid_api_key! unless p[:basic]
      when :curator
        missing_api_key! if p[:anonymous]
        invalid_api_key! unless p[:basic]
        unauthorized_api_key! unless p[:curator]
      when :admin
        missing_api_key! if p[:anonymous]
        invalid_api_key! unless p[:basic]
        unauthorized_api_key! unless p[:admin]
      else
        raise "Unexpected parameter"
      end
    end
  end

  if const_defined?("OldBase")
    class OldBase
      helpers PermissionHelpers
    end
  end

end
