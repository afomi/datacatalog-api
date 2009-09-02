module DataCatalog

  class Root < Base

    get '/?' do
      validate_no params
      {
        "name"      => "National Data Catalog API",
        "creator"   => "The Sunlight Labs",
        "version"   => "0.10",
        "resources" => {
          "/"       => full_uri("/"),
          "checkup" => full_uri("checkup"),
        }
      }.to_json
    end

  end
  
end