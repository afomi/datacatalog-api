require File.dirname(__FILE__) + '/users'

module DataCatalog

  class UsersKeys < Base
    include Resource

    parent Users
    child_association :api_keys
    model ApiKey
    path 'keys'

    # == Permissions

    roles Roles
    permission :list   => :basic # perhaps should be :owner_of_parent
    permission :read   => :owner
    permission :create => :basic # perhaps should be :owner_of_parent
    permission :update => :owner
    permission :delete => :owner
    
    # == Properties

    property :api_key
    property :key_type
    property :purpose
    
    # == Callbacks
    
    callback :before_destroy do |action, api_key, user|
      if api_key.key_type == 'primary'
        action.error(409, action.convert({
          'errors' => ['cannot_delete_primary_api_key']
        }))
      end
    end
    
    VALID_KEY_TYPES = %w(application valet)

    # Note: Needed because MongoMapper does not support validations on
    # EmbeddedDocuments.
    callback :before_create do |action, user|
      key_type = action.params['key_type']
      unless key_type
        action.error(400, action.convert({
          'errors' => { 'missing_params' => ['key_type'] }
        }))
      end
      unless VALID_KEY_TYPES.include?(key_type)
        action.error(400, action.convert({
          'errors' => {
            'invalid_values_for_params' => ['key_type']
          },
          'hints' => {
            'acceptable_values_for_params' => {
              "key_type" => VALID_KEY_TYPES
            }
          },
          'help_text' => "valid values for key_type are 'application' or 'valet'"
        }))
      end
      action.params['api_key'] = user.generate_api_key
    end

    callback :before_update do |action, api_key, user|
      key_type = action.params["key_type"]
      if key_type && api_key.key_type == "primary"
        action.error(400, action.convert({
          'errors' => {
            'invalid_values_for_params' => ['key_type'],
          },
          'hints' => {},
          'help_text' => 'cannot change the key_type of a primary key'
        }))
      elsif key_type && !VALID_KEY_TYPES.include?(key_type)
        action.error(400, action.convert({
          'errors' => {
            'invalid_values_for_params' => ['key_type']
          },
          'hints' => {
            'acceptable_values_for_params' => {
              "key_type" => VALID_KEY_TYPES
            }
          },
          'help_text' => "valid values for key_type are 'application' or 'valet'"
        }))
      end
    end

  end
  
  UsersKeys.build

end
