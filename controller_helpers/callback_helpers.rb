module DataCatalog
  
  module CallbackHelpers
    def callback(callback)
      return unless callback
      instance_eval(&callback)
    end
  end

  if const_defined?("OldBase")
    class OldBase
      helpers CallbackHelpers
    end
  end

end
