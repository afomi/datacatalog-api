def validate_api_key_params(kind)
  unless [:on_update, :on_create].include?(kind)
    raise "parameter must be :on_create or :on_update"
  end

  validate_params ApiKey, %w(
    api_key
    created_at
  )

  unless params["key_type"]
    case kind
    when :on_update
      return
    when :on_create
      error 400, { "errors" => { "missing_params" => ["key_type"] } }.to_json
    end
  end
    
  unless %w(application valet).include?(params["key_type"])
    error 400, {
      "errors" => {
        "invalid_values_for_params" => ["key_type"],
      },
      "help_text" => "valid values for key_type are 'application' or 'valet'"
    }.to_json
  end
end
