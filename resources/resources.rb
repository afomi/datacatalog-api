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
      { "href" => "/catalogs" },
      { "href" => "/categories" },
      { "href" => "/comments" },
      { "href" => "/documents" },
      { "href" => "/downloads" },
      { "href" => "/favorites" },
      { "href" => "/importers" },
      { "href" => "/imports" },
      { "href" => "/notes" },
      { "href" => "/organizations" },
      { "href" => "/ratings" },
      { "href" => "/sources" },
      { "href" => "/source_groups" },
      { "href" => "/tags" },
      { "href" => "/users" },
    ] + ANONYMOUS_MEMBERS
    
    CURATOR_MEMBERS = [
      { "href" => "/broken_links" },
      { "href" => "/reports" },
    ] + BASIC_MEMBERS

    get '/?' do
      members = case lookup_role
      when nil
        invalid_api_key!
      when :anonymous
        ANONYMOUS_MEMBERS
      when :basic
        BASIC_MEMBERS
      when :curator, :admin
        CURATOR_MEMBERS
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
