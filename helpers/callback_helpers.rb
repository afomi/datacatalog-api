module DataCatalog
  
  module CallbackHelpers
    def callback(callback)
      return unless callback
      instance_eval &callback
    end
  end

  class Base
    helpers CallbackHelpers
  end

end
