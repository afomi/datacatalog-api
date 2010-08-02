require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class ReportsGetAllTest < RequestTestCase

  def app; DataCatalog::Reports end

  context "0 reports" do
    context "normal API key : get /" do
      before do
        get "/", :api_key => @curator_user.primary_api_key
      end

      use "return 200 Ok"
      use "return an empty list of members"
    end
  end

  context "3 reports" do
    before do
      @user = create_user
      @reports = 3.times.map do |n|
        create_report(
          :text      => "Report #{n}",
          :user_id   => @user.id,
          :status    => 'new'
        )
      end
    end

    after do
      @reports.each { |x| x.destroy }
      @user.destroy
    end

    context "normal API key : get /" do
      before do
        get "/", :api_key => @curator_user.primary_api_key
        @members = parsed_response_body['members']
      end

      test "body should have 3 top level elements" do
        assert_equal 3, @members.length
      end

      test "body should have correct text" do
        actual = (0 ... 3).map { |n| @members[n]["text"] }
        3.times { |n| assert_include "Report #{n}", actual }
      end
    end
  end

end
