module DataCatalog

  module ValidationHelpers

    def validate_before_find(params, model)
      all_keys = model.keys.keys
      invalid_params = params.keys - all_keys
      unless invalid_params.empty?
        error 400, {
          "errors" => {
            "invalid_params" => invalid_params
          }
        }.to_json
      end
    end

    def validate_before_create(params, model, read_only_attributes)
      validate_before_save params, model, read_only_attributes
    end

    def validate_before_update(params, model, read_only_attributes)
      validate_before_save params, model, read_only_attributes
      if params.empty?
        error 400, {
          "errors"    => ["no_params_to_save"],
          "help_text" => "cannot save without parameters"
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
    
    protected
    
    def validate_before_save(params, model, read_only_attributes)
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

  end

  class Base
    helpers ValidationHelpers
  end

end
