module DataCatalog

  module SearchHelpers

    def find_with_filters(params, model)
      return(model.find(:all)) if params.empty?
      conditions = build_conditions_hash(params, model)
      model.find(:all, :conditions => conditions)
    end
    
    protected
    
    PATTERNS = [
      [ %r{^<=(.*)} , '$lte' ],
      [ %r{^<(.*)}  , '$lt'  ],
      [ %r{^>=(.*)} , '$gte' ],
      [ %r{^>(.*)}  , '$gt'  ]
    ]
    
    def build_conditions_hash(params, model)
      conditions = {}
      params.each do |key_string, value|
        result = nil
        PATTERNS.each do |m|
          if m[0] =~ value
            result = { m[1] => typecast(model, key_string, $1) }
            break
          end
        end
        conditions[key_string.intern] = if result
          result
        else
          typecast(model, key_string, value)
        end
      end
      conditions
    end
    
    def typecast(model, key_string, value)
      dummy = model.new
      dummy.send(:"#{key_string}=", value)
      dummy.send(:"#{key_string}")
    end

  end

  if const_defined?("OldBase")
    class OldBase
      helpers SearchHelpers
    end
  end
end
