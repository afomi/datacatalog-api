module DataCatalog

  class Checkup < Base

    get '/?' do
      privileges = privileges_for_api_key
      basic = {
        "anonymous"     => false,
        "valid_api_key" => true,
      }
      basic.merge!("user_id" => @current_user.id) if @current_user
      hash =
        if privileges[:anonymous]
          { "anonymous" => true }
        elsif privileges[:admin]
          basic.merge("admin" => true)
        elsif privileges[:curator]
          basic.merge("curator" => true)
        elsif privileges[:basic]
          basic
        else
          { "valid_api_key" => false }
        end
      hash.to_json
    end

  end

end
