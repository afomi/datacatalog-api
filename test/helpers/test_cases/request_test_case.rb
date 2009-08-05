class RequestTestCase < Test::Unit::TestCase

  def app
    Sinatra::Application
  end
  
  include Rack::Test::Methods
  include ModelHelpers
  include VariousHelpers
  include RequestHelpers

  before :all do
    reset_users
    @admin_user       = create_admin_user
    @confirmed_user   = create_confirmed_user
    @unconfirmed_user = create_unconfirmed_user
    reset_sources
  end
  
  class << self
    alias original_context context
    
    def context(name, &block)
      klass = original_context(name, &block)
      klass.class_eval do
        test "should have JSON content type" do
          assert_equal "application/json", last_response.headers["Content-Type"]
        end
      end
    end
  end

end
