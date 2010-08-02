require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class ReportsGetOneTest < RequestTestCase

  def app; DataCatalog::Reports end

  before do
    @user = create_user
    @report = create_report(
      :text      => "Report A",
      :user_id   => @user.id,
      :status    => 'new'
    )
  end

  after do
    @report.destroy
    @user.destroy
  end

  context "normal API key : get /:id" do
    before do
      get "/#{@report.id}", :api_key => @curator_user.primary_api_key
    end

    use "return 200 Ok"

    test "body should have correct text" do
      assert_equal "Report A", parsed_response_body["text"]
    end

    doc_properties %w(
      created_at
      id
      log
      object
      status
      text
      updated_at
      user_id
    )
  end

end
