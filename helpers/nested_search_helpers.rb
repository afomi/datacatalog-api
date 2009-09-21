module DataCatalog

  module NestedSearchHelpers

    # Note: not as full-featured as SearchHelpers.find.
    def nested_find(documents, params, model)
      documents.select do |document|
        match = true
        params.each do |key_string, value|
          unless document[key_string] == value
            match = false
          end
        end
        match
      end
    end
    
  end

  if const_defined?("Base")
    class Base
      helpers NestedSearchHelpers
    end
  end

end
