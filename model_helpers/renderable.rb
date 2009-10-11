module Renderable

  def self.included(other_module)
    other_module.extend(ClassMethods)
  end
  
  module ClassMethods
    def derived_methods
      @derived_methods
    end

    def derived_key(method)
      @derived_methods ||= []
      @derived_methods << method
    end
  end
  
  def render
    to_json(
      :methods => self.class.derived_methods
    )
  end

end

class Array
  def render
    '[%s]' % map(&:render).join(',')
  end
end
