require 'digest/sha1'

class RequestTestCase < Test::Unit::TestCase

  include Rack::Test::Methods
  include ModelHelpers
  include VariousHelpers
  include RequestHelpers

  before :all do
    [
      BrokenLink,
      Categorization,
      Catalog,
      Category,
      Comment,
      Document,
      Download,
      Favorite,
      Note,
      Organization,
      Rating,
      Report,
      Source,
      SourceGroup,
      Tag,
      User,
    ].each { |m| m.destroy_all }
    @normal_user = create_normal_user
    @curator_user = create_curator_user
    @admin_user = create_admin_user
  end

  def primary_api_key_for(role)
    instance_variable_get("@#{role}_user").primary_api_key
  end

  BAD_API_KEY = Digest::SHA1.hexdigest("invalid api key")

end
