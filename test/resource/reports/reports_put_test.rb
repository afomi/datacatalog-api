require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class ReportsPutTest < RequestTestCase

  def app; DataCatalog::Reports end

  before do
    @user = create_user
    @report = create_report(
      :text      => "Original Report",
      :user_id   => @user.id,
      :status    => 'new'
    )
    @report_count = Report.count
  end

  after do
    @report.destroy
    @user.destroy
  end

  context "admin API key : put /:id with invalid param" do
    before do
      put "/#{@report.id}", {
        :api_key => @admin_user.primary_api_key,
        :user_id => @admin_user.id
      }
    end

    test "body should say 'created_at' is an invalid param" do
      assert_include "errors", parsed_response_body
      assert_include "invalid_params", parsed_response_body["errors"]
      assert_include "user_id", parsed_response_body["errors"]["invalid_params"]
    end
  end

  context "admin API key : put /:id with correct param" do
    before do
      put "/#{@report.id}", {
        :api_key => @admin_user.primary_api_key,
        :text    => "New Report"
      }
    end

    use "return 200 Ok"
    use "unchanged report count"

    test "text should be updated in database" do
      report = Report.find_by_id!(@report.id)
      assert_equal "New Report", report.text
    end
  end

end
