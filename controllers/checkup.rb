module DataCatalog

  class Checkup < Base

    get '/?' do
      @privileges = privileges_for_api_key
      basic = {
        "anonymous"     => false,
        "valid_api_key" => true,
        "resources" => {
          "/"             => full_uri("/"),
          "checkup"       => full_uri("checkup"),
          "comments"      => full_uri("comments"),
          "documents"     => full_uri("documents"),
          "organizations" => full_uri("organizations"),
          "sources"       => full_uri("sources"),
          "users"         => full_uri("users")
        }
      }
      hash = if @privileges[:anonymous]
        {
          "anonymous" => true,
          "resources" => {
            "/"            => full_uri("/"),
            "checkup"      => full_uri("checkup"),
          }
        }
      elsif @privileges[:admin]
        basic.merge("admin" => true)
      elsif @privileges[:curator]
        basic.merge("curator" => true)
      elsif @privileges[:basic]
        basic
      else
        { "valid_api_key" => false }
      end
      hash.to_json
    end

  end

end
