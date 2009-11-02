module DataCatalog

  class Resources < Base
    include Resource
    
    # TODO: It should be possible for sinatra_resource to generate this
    # resource (a resource that lists other resources) automatically.
    # It would just need to look at the permissions. A good place to tie
    # in would be the `build` method.
    
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
      members = case lookup_role
      when nil
        invalid_api_key!
      when :anonymous
        ANONYMOUS_MEMBERS
      when :basic, :curator, :admin
        BASIC_MEMBERS
      else
        raise Error, "unexpected role"
      end
      convert({
        "members" => members,
        "next"    => nil
      })
    end

  end

end
