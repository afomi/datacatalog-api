require File.expand_path(File.dirname(__FILE__) + '/../test_other_helper')

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
  
  LEVELS = [:anonymous, :basic, :curator, :admin]
  
  def for_all_levels
    LEVELS.each { |level| yield(level) }
  end
  
  context "#permission_check" do
    context "fake" do
      before do
        self.params = { "api_key" => get_fake_api_key("John Doe") }
      end
      
      it "anonymous" do
        error_expected(401, INVALID) do
          permission_check(:level => :anonymous)
        end
        for_all_levels do |level|
          error_expected(401, INVALID) do
            permission_check(:default => level, :override => :anonymous)
          end
        end
      end
      
      it "basic" do
        error_expected(401, INVALID) do
          permission_check(:level => :basic)
        end
        for_all_levels do |level|
          error_expected(401, INVALID) do
            permission_check(:default => level, :override => :basic)
          end
        end
      end
      
      it "curator" do
        error_expected(401, INVALID) do
          permission_check(:level => :curator)
        end
        for_all_levels do |level|
          error_expected(401, INVALID) do
            permission_check(:default => level, :override => :curator)
          end
        end
      end
      
      it "admin" do
        error_expected(401, INVALID) do
          permission_check(:level => :admin)
        end
        for_all_levels do |level|
          error_expected(401, INVALID) do
            permission_check(:default => level, :override => :admin)
          end
        end
      end
    end

    context "anonymous" do
      before do
        self.params = {}
      end
      
      it "anonymous" do
        permission_check(:level => :anonymous)
        for_all_levels do |level|
          permission_check(:default => level, :override => :anonymous)
        end
      end
      
      it "basic" do
        error_expected(401, MISSING) do
          permission_check(:level => :basic)
        end
        for_all_levels do |level|
          error_expected(401, MISSING) do
            permission_check(:default => level, :override => :basic)
          end
        end
      end
      
      it "curator" do
        error_expected(401, MISSING) do
          permission_check(:level => :curator)
        end
        for_all_levels do |level|
          error_expected(401, MISSING) do
            permission_check(:default => level, :override => :curator)
          end
        end
      end
      
      it "admin" do
        error_expected(401, MISSING) do
          permission_check(:level => :admin)
        end
        for_all_levels do |level|
          error_expected(401, MISSING) do
            permission_check(:default => level, :override => :admin)
          end
        end
      end
    end

    context "normal user" do
      before do
        self.params = { "api_key" => @normal_user.primary_api_key }
      end
      
      it "anonymous" do
        permission_check(:level => :anonymous)
        for_all_levels do |level|
          permission_check(:default => level, :override => :anonymous)
        end
      end
      
      it "basic" do
        permission_check(:level => :basic)
        for_all_levels do |level|
          permission_check(:default => level, :override => :basic)
        end
      end
      
      it "curator" do
        error_expected(401, UNAUTHORIZED) do
          permission_check(:level => :curator)
        end
        for_all_levels do |level|
          error_expected(401, UNAUTHORIZED) do
            permission_check(:default => level, :override => :curator)
          end
        end
      end
      
      it "admin" do
        error_expected(401, UNAUTHORIZED) do
          permission_check(:level => :admin)
        end
        for_all_levels do |level|
          error_expected(401, UNAUTHORIZED) do
            permission_check(:default => level, :override => :admin)
          end
        end
      end
    end

    context "curator user" do
      before do
        self.params = { "api_key" => @curator_user.primary_api_key }
      end
      
      it "anonymous" do
        permission_check(:level => :anonymous)
        for_all_levels do |level|
          permission_check(:default => level, :override => :anonymous)
        end
      end
      
      it "basic" do
        permission_check(:level => :basic)
        for_all_levels do |level|
          permission_check(:default => level, :override => :basic)
        end
      end
      
      it "curator" do
        permission_check(:level => :curator)
        for_all_levels do |level|
          permission_check(:default => level, :override => :curator)
        end
      end
      
      it "admin" do
        error_expected(401, UNAUTHORIZED) do
          permission_check(:level => :admin)
        end
        for_all_levels do |level|
          error_expected(401, UNAUTHORIZED) do
            permission_check(:default => level, :override => :admin)
          end
        end
      end
    end

    context "admin user" do
      before do
        self.params = { "api_key" => @admin_user.primary_api_key }
      end
      
      it "anonymous" do
        permission_check(:level => :anonymous)
        for_all_levels do |level|
          permission_check(:default => level, :override => :anonymous)
        end
      end
      
      it "basic" do
        permission_check(:level => :basic)
        for_all_levels do |level|
          permission_check(:default => level, :override => :basic)
        end
      end
      
      it "curator" do
        permission_check(:level => :curator)
        for_all_levels do |level|
          permission_check(:default => level, :override => :curator)
        end
      end
      
      it "admin" do
        permission_check(:level => :admin)
        for_all_levels do |level|
          permission_check(:default => level, :override => :admin)
        end
      end
    end
  end

  context "#privileges" do
    it "anonymous" do
      self.params = {}
      expected = {
        :admin     => false,
        :curator   => false,
        :basic     => false,
        :anonymous => true
      }
      assert_equal expected, privileges
    end

    it "fake user" do
      self.params = { "api_key" => get_fake_api_key("John Doe") }
      expected = {
        :admin     => false,
        :curator   => false,
        :basic     => false,
        :anonymous => false
      }
      assert_equal expected, privileges
    end

    it "normal user" do
      self.params = { "api_key" => @normal_user.primary_api_key }
      expected = {
        :admin     => false,
        :curator   => false,
        :basic     => true,
        :anonymous => false
      }
      assert_equal expected, privileges
    end

    it "curator user" do
      self.params = { "api_key" => @curator_user.primary_api_key }
      expected = {
        :admin     => false,
        :curator   => true,
        :basic     => true,
        :anonymous => false
      }
      assert_equal expected, privileges
    end

    it "admin user" do
      self.params = { "api_key" => @admin_user.primary_api_key }
      expected = {
        :admin     => true,
        :curator   => true,
        :basic     => true,
        :anonymous => false
      }
      assert_equal expected, privileges
    end
  end

end
