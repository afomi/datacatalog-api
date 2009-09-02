module DataCatalog
  
  module CallbackHelpers
    def callback(callback, document)
      return unless callback
      @document = document # for use by callback
      instance_eval &callback
    end
  end

  class Base
    helpers CallbackHelpers
  end

end
