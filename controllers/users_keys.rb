module DataCatalog

  class UsersKeys < Nested

    restful_routes do
      name "keys"

      association :api_keys

      model ApiKey, :read_only => [
        :api_key,
        :created_at
      ]

      permission :owner

      callback :before_destroy do
        if @child_document.key_type == "primary"
          error 403, {
            "errors" => ["cannot_delete_primary_api_key"],
            "help_text" => "cannot delete a primary API key"
          }.to_json
        end
      end
      
      callback :before_create do
        key_type = params["key_type"]
        unless key_type
          error 400, { "errors" => { "missing_params" => ["key_type"] } }.to_json
        end
        unless %w(application valet).include?(key_type)
          error 400, {
            "errors" => {
              "invalid_values_for_params" => ["key_type"],
            },
            "help_text" => "valid values for key_type are 'application' or 'valet'"
          }.to_json
        end
        params["api_key"] = @parent_document.generate_api_key
      end
      
      callback :before_update do
        key_type = params["key_type"]
        if @child_document.key_type == "primary"
          error 400, {
            "errors" => {
              "invalid_values_for_params" => ["key_type"],
            },
            "help_text" => "cannot change the key_type of a primary key"
          }.to_json
        end
        if key_type && !%w(application valet).include?(key_type)
          error 400, {
            "errors" => {
              "invalid_values_for_params" => ["key_type"],
            },
            "help_text" => "valid values for key_type are 'application' or 'valet'"
          }.to_json
        end
      end
      
    end
  
  end

end
