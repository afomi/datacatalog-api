module DataCatalog

  class Checkup < OldBase

    get '/?' do
      p = privileges
      basic = {
        "anonymous"     => false,
        "valid_api_key" => true,
      }
      if @current_user
        basic.merge!({
          "user" => {
            "href" => "/users/#{@current_user.id}",
            "id"   => @current_user.id
          }
        })
      end
      hash =
        if p[:anonymous]
          { "anonymous" => true }
        elsif p[:admin]
          basic.merge("admin" => true)
        elsif p[:curator]
          basic.merge("curator" => true)
        elsif p[:basic]
          basic
        else
          { "valid_api_key" => false }
        end
      hash.to_json
    end

  end

end
