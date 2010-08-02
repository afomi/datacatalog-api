module DataCatalog

  class Root < Base
    include Resource

    META = {
      "name"    => "National Data Catalog API",
      "version" => "0.4.11",
      "resource_directory" => {
        "href" => "/resources"
      },
      "creator" => {
        "name" => "The Sunlight Labs",
        "href" => "http://sunlightlabs.com"
      },
      "project_page" => {
        "href" => "http://sunlightlabs.com/projects/datacatalog/"
      },
      "source_code" => {
        "href" => "http://github.com/sunlightlabs/datacatalog-api"
      },
      "documentation" => {
        "href" => "http://api.nationaldatacatalog.com/docs/"
      },
    }

    get '/?' do
      case lookup_role
      when nil
        invalid_api_key!
      when :anonymous, :basic, :curator, :admin
        convert(META)
      else
        raise Error, "unexpected role"
      end
    end

  end

end