require File.expand_path(File.dirname(__FILE__) + '/../test_unit_helper')

class ReportUnitTest < ModelTestCase

  shared "valid report" do
    test "should be valid" do
      assert_equal true, @report.valid?
    end
  end

  shared "invalid report" do
    test "should not be valid" do
      assert_equal false, @report.valid?
    end
  end

  shared "report.text can't be empty" do
    test "should have error on text" do
      @report.valid?
      assert_include :text, @report.errors.errors
      assert_include "can't be empty", @report.errors.errors[:text]
    end
  end

  shared "report.user_id can't be empty" do
    test "should have error on user_id" do
      @report.valid?
      assert_include :user_id, @report.errors.errors
      assert_include "can't be empty", @report.errors.errors[:user_id]
    end
  end

  shared "report.status must be valid" do
    test "should have error on status" do
      @report.valid?
      assert_include :status, @report.errors.errors
      assert_include "must be one of: new, open, closed",
        @report.errors.errors[:status]
    end
  end
  
  context "Report.new" do
    before do
      @user = create_user
      @valid_params = {
        :text      => "An explanation",
        :user_id   => @user.id,
        :status    => "new",
      }
    end
    
    after do
      @user.destroy
    end
    
    context "missing text" do
      before do
        @report = Report.new(@valid_params.merge(:text => ""))
      end
      
      use "invalid report"
      use "report.text can't be empty"
    end
    
    context "missing user_id" do
      before do
        @report = Report.new(@valid_params.merge(:user_id => nil))
      end
      
      use "invalid report"
      use "report.user_id can't be empty"
    end

    context "invalid status" do
      before do
        @report = Report.new(@valid_params.merge(:status => ""))
      end
      
      use "invalid report"
      use "report.status must be valid"
    end

    context "correct params" do
      before do
        @report = Report.new(@valid_params)
      end
      
      use "valid report"
    end
  end

end
