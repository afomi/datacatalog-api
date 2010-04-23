require 'uri'

module DataCatalog
    
  module Resource
    
    def self.included(includee)
      includee.instance_eval do
        include SinatraResource::Resource
      end
      
      includee.helpers do

        attr_accessor :current_user

        def before_authorization(action, role, resource_config)
          unless role
            error 401, convert(body_for(:errors, ["invalid_api_key"]))
          end
          if role == :anonymous && minimum_role(action, resource_config) != :anonymous
            error 401, convert(body_for(:errors, ["missing_api_key"]))
          end
        end

        # Required for SinatraResource
        def convert(object)
          object == "" ? "" : object.to_json
        end

        def full_uri(path)
          base_uri = Config.environment_config["base_uri"]
          URI.join(base_uri, path).to_s
        end

        def invalid_api_key!
          error 401, convert({
            "errors" => ["invalid_api_key"]
          })
        end
        
        # Callback from SinatraResource
        def log_event(event, params)
          case event
          when :get_many
            search_string = params['search']
            if search_string
              words = search_string.downcase.split(" ")
              SearchEvent.create!(:event => 'search', :words => words)
            end
          end
        end

        # Required for SinatraResource
        def lookup_role(document=nil)
          api_key = lookup_api_key
          return :anonymous unless api_key
          user = user_for(api_key)
          self.current_user = user
          return nil unless user
          return :owner if document && owner?(user, document)
          user.role.intern
        end

        protected

        def lookup_api_key
          @api_key ||= params.delete("api_key")
        end
        
        # Is +user+ the owner of +document+?
        #
        # First, checks to see if +user+ and +document+ are the same. After
        # that, try to follow the +document.user+ relationship, if present, to
        # see if that points to +user+.
        #
        # Note that certain document classes are ignored (e.g. Report) because
        # "ownership" is not a useful idea -- or worse, because returning
        # :owner as the role would trump :curator or :admin.
        #
        # @param [DataCatalog::User] user
        #
        # @param [MongoMapper::Document] user
        #
        # @return [Boolean]
        def owner?(user, document)
          if [Report].include?(document.class)
            false
          elsif user == document
            true
          elsif !document.respond_to?(:user)
            false
          else
            document.user == user
          end
        end

        def user_for(api_key)
          user = User.find_by_api_key(api_key)
          return nil unless user
          raise "API key found, but user has no role" unless user.role
          user
        end

      end
    end

  end
  
end
