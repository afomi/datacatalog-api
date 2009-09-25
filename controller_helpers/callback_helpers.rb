module DataCatalog
  
  module CallbackHelpers
    def callback(callback)
      return unless callback
      instance_eval(&callback)
    end
  end

  if const_defined?("Base")
    class Base
      helpers CallbackHelpers
    end
  end

end
