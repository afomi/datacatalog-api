require File.expand_path(File.dirname(__FILE__) + '/../test_functional_helper')

class CategoryUnitTest < ModelTestCase

  include DataCatalog::PermissionHelpers
  
  before :all do
    User.destroy_all
    @normal_user = create_normal_user
    @another_normal_user = create_another_normal_user
    @curator_user = create_curator_user
    @admin_user = create_admin_user
  end

  attr_accessor :params
  
  def error(code, message)
    @errors << [code, message]
  end

  MISSING_API_KEY      = [401, %<{"errors":["missing_api_key"]}>]
  INVALID_API_KEY      = [401, %<{"errors":["invalid_api_key"]}>]
  UNAUTHORIZED_API_KEY = [401, %<{"errors":["unauthorized_api_key"]}>]
  
  context "#require_at_least" do
    before do
      @errors = []
    end
    
    context "fake" do
      before do
        self.params = { "api_key" => get_fake_api_key("John Doe") }
      end
      
      it "anonymous" do
        require_at_least(:anonymous)
        assert_equal [INVALID_API_KEY], @errors
      end
      
      it "basic" do
        require_at_least(:basic)
        assert_equal [INVALID_API_KEY], @errors
      end
      
      it "curator" do
        require_at_least(:curator)
        assert_equal [INVALID_API_KEY], @errors
      end
      
      it "admin" do
        require_at_least(:admin)
        assert_equal [INVALID_API_KEY], @errors
      end
    end

    context "anonymous" do
      before do
        self.params = {}
      end
      
      it "anonymous" do
        require_at_least(:anonymous)
        assert_equal [], @errors
      end
      
      it "basic" do
        require_at_least(:basic)
        assert_equal [MISSING_API_KEY], @errors
      end
      
      it "curator" do
        require_at_least(:curator)
        assert_equal [MISSING_API_KEY], @errors
      end
      
      it "admin" do
        require_at_least(:admin)
        assert_equal [MISSING_API_KEY], @errors
      end
    end

    context "normal user" do
      before do
        self.params = { "api_key" => @normal_user.primary_api_key }
      end
      
      it "anonymous" do
        require_at_least(:anonymous)
        assert_equal [], @errors
      end
      
      it "basic" do
        require_at_least(:basic)
        assert_equal [], @errors
      end
      
      it "curator" do
        require_at_least(:curator)
        assert_equal [UNAUTHORIZED_API_KEY], @errors
      end
      
      it "admin" do
        require_at_least(:admin)
        assert_equal [UNAUTHORIZED_API_KEY], @errors
      end
    end

    context "curator user" do
      before do
        self.params = { "api_key" => @curator_user.primary_api_key }
      end
      
      it "anonymous" do
        require_at_least(:anonymous)
        assert_equal [], @errors
      end
      
      it "basic" do
        require_at_least(:basic)
        assert_equal [], @errors
      end
      
      it "curator" do
        require_at_least(:curator)
        assert_equal [], @errors
      end
      
      it "admin" do
        require_at_least(:admin)
        assert_equal [UNAUTHORIZED_API_KEY], @errors
      end
    end

    context "admin user" do
      before do
        self.params = { "api_key" => @admin_user.primary_api_key }
      end
      
      it "anonymous" do
        require_at_least(:anonymous)
        assert_equal [], @errors
      end
      
      it "basic" do
        require_at_least(:basic)
        assert_equal [], @errors
      end
      
      it "curator" do
        require_at_least(:curator)
        assert_equal [], @errors
      end
      
      it "admin" do
        require_at_least(:admin)
        assert_equal [], @errors
      end
    end
  end
  
  context "#privileges_for_api_key" do
    it "anonymous" do
      self.params = {}
      expected = {
        :admin     => false,
        :curator   => false,
        :owner     => false,
        :basic     => false,
        :anonymous => true
      }
      assert_equal expected, privileges_for_api_key
    end

    it "fake user" do
      self.params = { "api_key" => get_fake_api_key("John Doe") }
      expected = {
        :admin     => false,
        :curator   => false,
        :owner     => false,
        :basic     => false,
        :anonymous => false
      }
      assert_equal expected, privileges_for_api_key
    end
    
    it "normal user" do
      self.params = { "api_key" => @normal_user.primary_api_key }
      expected = {
        :admin     => false,
        :curator   => false,
        :owner     => false,
        :basic     => true,
        :anonymous => false
      }
      assert_equal expected, privileges_for_api_key
    end

    it "another normal user - not the owner" do
      self.params = { "api_key" => @another_normal_user.primary_api_key }
      expected = {
        :admin     => false,
        :curator   => false,
        :owner     => false,
        :basic     => true,
        :anonymous => false
      }
      assert_equal expected, privileges_for_api_key(@normal_user.id)
    end
    
    it "owner user" do
      self.params = { "api_key" => @normal_user.primary_api_key }
      expected = {
        :admin     => false,
        :curator   => false,
        :owner     => true,
        :basic     => true,
        :anonymous => false
      }
      assert_equal expected, privileges_for_api_key(@normal_user.id)
    end

    it "curator user" do
      self.params = { "api_key" => @curator_user.primary_api_key }
      expected = {
        :admin     => false,
        :curator   => true,
        :owner     => true,
        :basic     => true,
        :anonymous => false
      }
      assert_equal expected, privileges_for_api_key
    end

    it "admin user" do
      self.params = { "api_key" => @admin_user.primary_api_key }
      expected = {
        :admin     => true,
        :curator   => true,
        :owner     => true,
        :basic     => true,
        :anonymous => false
      }
      assert_equal expected, privileges_for_api_key
    end
  end

end
