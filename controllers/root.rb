get '/' do
  validate_root_params
  {
    "name"      => "National Data Catalog API",
    "creator"   => "The Sunlight Labs",
    "version"   => "0.10",
    "resources" => [
      { "sources" => full_uri("sources") }
    ]
  }.to_json
end
