module DataCatalog

  class Resources < Base
    
    ANONYMOUS_MEMBERS = [
      { "href" => "/" },
      { "href" => "/checkup" },
      { "href" => "/resources" },
    ]
    
    BASIC_MEMBERS = [
      { "href" => "/categories" },
      { "href" => "/comments" },
      { "href" => "/documents" },
      { "href" => "/notes" },
      { "href" => "/organizations" },
      { "href" => "/ratings" },
      { "href" => "/sources" },
      { "href" => "/tags" },
      { "href" => "/users" },
    ] + ANONYMOUS_MEMBERS

    get '/?' do
      p = privileges_for_api_key
      members = if p[:admin] || p[:curator] || p[:basic]
        BASIC_MEMBERS
      elsif p[:anonymous]
        ANONYMOUS_MEMBERS
      else
        invalid_api_key!
      end
      {
        "members" => members,
        "next"    => nil
      }.to_json
    end

  end

end
