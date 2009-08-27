def validate_organization_params
  validate_params Organization, %w(
    user_id
    created_at
    updated_at
  )
end

def create_organization_from_params
  document = Organization.create(params)
  response.status = 201
  response.headers['Location'] = full_uri('/organizations/' + document.id)
  document
end
