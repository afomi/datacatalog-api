# 201 Created
module Status201

  def self.included(mod)
    mod.test "status should be 201 Created" do
      assert_equal 201, last_response.status
    end
    
    mod.test "location header should start with http://localhost" do
      assert_include "Location", last_response.headers
      generic_uri = %r{^http://localhost}
      assert_match generic_uri, last_response.headers["Location"]
    end
  end
  
end
