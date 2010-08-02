require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class ReportsDeleteTest < RequestTestCase

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
    @user.destroy
  end

  %w(admin).each do |role|
    context "#{role} API key : delete /:id" do
      before do
        delete "/#{@report.id}", :api_key => primary_api_key_for(role)
      end

      use "return 204 No Content"
      use "decremented report count"

      test "source should be deleted in database" do
        assert_equal nil, Report.find_by_id(@report.id)
      end
    end
  end

end
