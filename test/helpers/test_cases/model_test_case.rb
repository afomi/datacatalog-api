class ModelTestCase < Test::Unit::TestCase

  def app
    Sinatra::Application
  end
  
  include ModelHelpers
  include VariousHelpers
  
end
