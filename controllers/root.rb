get '/' do
  content_type :json
  {
    "name"        => "National Data Catalog API",
    "creator"     => "The Sunlight Labs",
    "version"     => 0.01,
    "resources"   => [
      { "sources" => full_uri("sources") }
    ]
  }.to_json
end
