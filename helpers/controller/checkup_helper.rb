module CheckupHelper

  def self.anonymous
    {
      "anonymous" => true,
      "resources" => {
        "/"            => full_uri("/"),
        "checkup"      => full_uri("checkup"),
      }
    }.to_json
  end

  def self.invalid_api_key
    {
      "valid_api_key" => false,
    }.to_json
  end

  def self.normal_api_key
    {
      "anonymous"     => false,
      "valid_api_key" => true,
      "resources" => {
        "/"             => full_uri("/"),
        "checkup"       => full_uri("checkup"),
        "comments"      => full_uri("comments"),
        "documents"     => full_uri("documents"),
        "organizations" => full_uri("organizations"),
        "sources"       => full_uri("sources"),
        "users"         => full_uri("users"),
      }
    }.to_json
  end

  def self.admin_api_key
    {
      "anonymous"     => false,
      "valid_api_key" => true,
      "admin"         => true,
      "resources" => {
        "/"             => full_uri("/"),
        "checkup"       => full_uri("checkup"),
        "comments"      => full_uri("comments"),
        "documents"     => full_uri("documents"),
        "organizations" => full_uri("organizations"),
        "sources"       => full_uri("sources"),
        "users"         => full_uri("users"),
      }
    }.to_json
  end

end
