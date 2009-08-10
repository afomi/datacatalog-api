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
    
    alias context_ context

    def context(name, &block)
      klass = context_(name, &block)
      klass.class_eval do
        use "return JSON"
      end
    end
    
  end

end
