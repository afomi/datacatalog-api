require File.expand_path(File.dirname(__FILE__) + '/../test_functional_helper')

class PermissionException < StandardError
  attr_accessor :status, :message

  def initialize(status, message)
    self.status = status
    self.message = message
  end
end

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
  
  def error(status, message)
    raise PermissionException.new(status, message)
  end
  
  def error_expected(status, message)
    begin
      yield
    rescue PermissionException => e
      assert_equal status, e.status
      assert_equal message, e.message
    end
  end

  MISSING      = %<{"errors":["missing_api_key"]}>
  INVALID      = %<{"errors":["invalid_api_key"]}>
  UNAUTHORIZED = %<{"errors":["unauthorized_api_key"]}>
  
  context "#require_at_least" do
    context "fake" do
      before do
        self.params = { "api_key" => get_fake_api_key("John Doe") }
      end
      
      it "anonymous" do
        error_expected(401, INVALID) do
          require_at_least(:anonymous)
        end
      end
      
      it "basic" do
        error_expected(401, INVALID) do
          require_at_least(:basic)
        end
      end
      
      it "curator" do
        error_expected(401, INVALID) do
          require_at_least(:curator)
        end
      end
      
      it "admin" do
        error_expected(401, INVALID) do
          require_at_least(:admin)
        end
      end
    end

    context "anonymous" do
      before do
        self.params = {}
      end
      
      it "anonymous" do
        require_at_least(:anonymous)
      end
      
      it "basic" do
        error_expected(401, MISSING) do
          require_at_least(:basic)
        end
      end
      
      it "curator" do
        error_expected(401, MISSING) do
          require_at_least(:curator)
        end
      end
      
      it "admin" do
        error_expected(401, MISSING) do
          require_at_least(:admin)
        end
      end      
    end

    context "normal user" do
      before do
        self.params = { "api_key" => @normal_user.primary_api_key }
      end
      
      it "anonymous" do
        require_at_least(:anonymous)
      end
      
      it "basic" do
        require_at_least(:basic)
      end
      
      it "curator" do
        error_expected(401, UNAUTHORIZED) do
          require_at_least(:curator)
        end
      end
      
      it "admin" do
        error_expected(401, UNAUTHORIZED) do
          require_at_least(:admin)
        end
      end
    end

    context "curator user" do
      before do
        self.params = { "api_key" => @curator_user.primary_api_key }
      end
      
      it "anonymous" do
        require_at_least(:anonymous)
      end
      
      it "basic" do
        require_at_least(:basic)
      end
      
      it "curator" do
        require_at_least(:curator)
      end
      
      it "admin" do
        error_expected(401, UNAUTHORIZED) do
          require_at_least(:admin)
        end
      end
    end

    context "admin user" do
      before do
        self.params = { "api_key" => @admin_user.primary_api_key }
      end
      
      it "anonymous" do
        require_at_least(:anonymous)
      end
      
      it "basic" do
        require_at_least(:basic)
      end
      
      it "curator" do
        require_at_least(:curator)
      end
      
      it "admin" do
        require_at_least(:admin)
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
