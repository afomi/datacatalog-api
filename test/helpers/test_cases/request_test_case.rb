class RequestTestCase < Test::Unit::TestCase

  include Rack::Test::Methods
  include ModelHelpers
  include VariousHelpers
  include RequestHelpers

  before :all do
    [
      Categorization,
      Category,
      Comment,
      Document,
      Note,
      Organization,
      Rating,
      Source,
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
