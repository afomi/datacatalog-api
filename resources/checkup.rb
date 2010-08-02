module DataCatalog

  class Checkup < Base
    include Resource

    get '/?' do
      hash = case lookup_role
      when nil
        {
          "api_key" => "invalid",
        }
      when :anonymous
        {
          "anonymous" => true,
          "api_key"   => "none",
          "role"      => "anonymous",
        }
      when :basic
        {
          "anonymous" => false,
          "api_key"   => "valid",
          "role"      => "basic",
          "user"      => {
            "href"    => "/users/#{current_user.id}",
            "id"      => current_user.id,
          }
        }
      when :curator
        {
          "anonymous" => false,
          "api_key"   => "valid",
          "role"      => "curator",
          "curator"   => true,
          "user"      => {
            "href"    => "/users/#{current_user.id}",
            "id"      => current_user.id,
          }
        }
      when :admin
        {
          "anonymous" => false,
          "api_key"   => "valid",
          "role"      => "admin",
          "curator"   => true,
          "admin"     => true,
          "user"      => {
            "href"    => "/users/#{current_user.id}",
            "id"      => current_user.id,
          }
        }
      else
        raise Error, "unexpected role"
      end
      convert(hash)
    end

  end

end
