def validate_api_key_params
  validate_params ApiKey, %w(
    api_key
    created_at
  )
end
