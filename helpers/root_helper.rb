def validate_root_params
  valid_params = []
  invalid_params = params.keys - valid_params
  unless invalid_params.empty?
    content = {
      "errors" => { "invalid_params" => invalid_params }
    }
    error 400, content.to_json
  end
end
