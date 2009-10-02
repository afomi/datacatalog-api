module DataCatalog

  module NestedSearchHelpers

    # Not as full-featured as SearchHelpers.find_with_filters
    def nested_find_with_filters(documents, params, model)
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
