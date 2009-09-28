module DataCatalog

  class Root < Base
    
    PROJECT_META_DATA = {
      "name"    => "National Data Catalog API",
      "version" => "0.2.1",
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
        "overview" => {
          "href" => "http://github.com/sunlightlabs/datacatalog-api/blob/master/doc/about.md"
        },
        "resource_details" => {
          "href" => "http://github.com/sunlightlabs/datacatalog-api/blob/master/doc/resources.md"
        },
      },
    }.to_json

    get '/?' do
      require_at_least(:anonymous)
      PROJECT_META_DATA
    end

  end
  
end