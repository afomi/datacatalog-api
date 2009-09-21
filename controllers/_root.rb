module DataCatalog

  class Root < Base

    get '/?' do
      require_at_least(:anonymous)
      {
        "name"               => "National Data Catalog API",
        "creator"            => "The Sunlight Labs",
        "version"            => "0.20",
        "resource_directory" => { "href" => "/resources" },
      }.to_json
    end

  end
  
end