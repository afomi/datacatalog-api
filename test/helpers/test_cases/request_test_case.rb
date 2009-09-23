class RequestTestCase < Test::Unit::TestCase

  include Rack::Test::Methods
  include ModelHelpers
  include VariousHelpers
  include RequestHelpers

  before :all do
    Category.destroy_all
    Comment.destroy_all
    Document.destroy_all
    Note.destroy_all
    Organization.destroy_all
    Rating.destroy_all
    Source.destroy_all
    Tag.destroy_all
    User.destroy_all
    @normal_user = create_normal_user
    @curator_user = create_curator_user
    @admin_user = create_admin_user
  end

  def primary_api_key_for(role)
    instance_variable_get("@#{role}_user").primary_api_key
  end

  class << self
    
    alias context_ context

    def context(name, &block)
      klass = context_(name, &block)
      klass.class_eval do
        use "return JSON"
      end
    end
    
  end

end
