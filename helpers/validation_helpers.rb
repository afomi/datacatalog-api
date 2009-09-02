module DataCatalog

  module ValidationHelpers

    def validate(params, model, read_only_attributes)
      invalid_keys = read_only_attributes.map { |x| x.to_s }
      all_keys = model.keys.keys
      valid_params = all_keys - invalid_keys
      invalid_params = params.keys - valid_params
      unless invalid_params.empty?
        error 400, {
          "errors" => {
            "invalid_params" => invalid_params
          }
        }.to_json
      end
    end
    
    def validate_no(params)
      valid_params = []
      invalid_params = params.keys - valid_params
      unless invalid_params.empty?
        content = {
          "errors" => { "invalid_params" => invalid_params }
        }
        error 400, content.to_json
      end
    end

  end

  class Base
    helpers ValidationHelpers
  end

end
