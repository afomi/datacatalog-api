def validate_source_params
  validate_params Source, []
end

def validate_user_params
  validate_params User, %w(
    api_keys
    confirmed
    admin
    creator_api_key
  )
end

def validate_params(model, invalid_keys)
  all_keys = model.keys.keys
  valid_params = all_keys - invalid_keys
  invalid_params = params.keys - valid_params
  unless invalid_params.empty?
    content = {
      "errors" => { "invalid_params" => invalid_params }
    }
    error 400, content.to_json
  end
end
