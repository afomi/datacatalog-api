require File.expand_path(File.dirname(__FILE__) + '/../../test_controller_helper')

class RatingsGetSearchControllerTest < RequestTestCase

  def app; DataCatalog::Ratings end
  
  def assert_shared_attributes(element)
    assert_include "created_at", element
    assert_include "updated_at", element
    assert_include "id", element
    assert_not_include "_id", element
  end
  
  shared "successful GET of ratings where value is 2" do
    test "body should have 1 top level element" do
      assert_equal 1, parsed_response_body.length
    end

    test "each element should be correct" do
      parsed_response_body.each do |element|
        assert_equal "source rating 2", element["text"]
        assert_equal 2, element["value"]
        assert_equal @user_id, element["user_id"]
        assert_shared_attributes element
      end
    end
  end

  shared "successful GET of ratings with value greater than or equal to 4" do
    test "body should have 2 top level elements" do
      assert_equal 2, parsed_response_body.length
    end

    test "each element should be correct" do
      parsed_response_body.each do |element|
        value = element["value"]
        assert_equal true, value >= 4
        assert_equal "source rating #{value}", element["text"]
        assert_equal @user_id, element["user_id"]
        assert_shared_attributes element
      end
    end
  end

  shared "successful GET of ratings with value less than 4" do
    test "body should have 5 top level elements" do
      assert_equal 5, parsed_response_body.length
    end

    test "each element should be correct" do
      parsed_response_body.each do |element|
        value = element["value"]
        assert_equal true, value < 4
        assert_equal @user_id, element["user_id"]
        case element["kind"]
        when "source"
          assert_include "source_id", element
          assert_equal "source rating #{value}", element["text"]
        when "comment"
          assert_include "comment_id", element
        else flunk "incorrect kind of rating"
        end
        assert_shared_attributes element
      end
    end
  end

  # - - - - - - - - - -

  context_ "7 ratings" do
    before do
      @user_id      = "4aa136f125b7e72c76000001"
      @source_base  = "4aa1370c25b7e72c7600000"
      @comment_base = "800139b125b7e72c7600000"
      5.times do |n|
        assert Rating.create(
          :kind      => "source",
          :value     => n + 1,
          :text      => "source rating #{n + 1}",
          :user_id   => @user_id,
          :source_id => "#{@source_base}#{n + 1}"
        ).valid?
      end
      2.times do |n|
        assert Rating.create(
          :kind       => "comment",
          :value      => n,
          :user_id    => @user_id,
          :comment_id => "#{@comment_base}#{n + 1}"
        ).valid?
      end
    end

    # - - - - - - - - - -

    context "normal API key : get / where value is 2" do
      before do
        get "/",
          :value   => 2,
          :api_key => @normal_user.primary_api_key
      end
    
      use "successful GET of ratings where value is 2"
    end

    context "admin API key : get / where value is 2" do
      before do
        get "/",
          :value   => 2,
          :api_key => @admin_user.primary_api_key
      end
    
      use "successful GET of ratings where value is 2"
    end

    # - - - - - - - - - -

    context "normal API key : get / with value greater than or equal to 4" do
      before do
        get "/",
          :value   => ">=4",
          :api_key => @normal_user.primary_api_key
      end
    
      use "successful GET of ratings with value greater than or equal to 4"
    end
    
    context "admin API key : get / with value greater than or equal to 4" do
      before do
        get "/",
          :value   => ">=4",
          :api_key => @admin_user.primary_api_key
      end
    
      use "successful GET of ratings with value greater than or equal to 4"
    end

    # - - - - - - - - - -

    context "normal API key : get / with value greater than 3" do
      before do
        get "/",
          :value   => ">3",
          :api_key => @normal_user.primary_api_key
      end
    
      use "successful GET of ratings with value greater than or equal to 4"
    end
    
    context "admin API key : get / with value greater than 3" do
      before do
        get "/",
          :value   => ">3",
          :api_key => @admin_user.primary_api_key
      end
    
      use "successful GET of ratings with value greater than or equal to 4"
    end

    # - - - - - - - - - -

    context "normal API key : get / with value less than 4" do
      before do
        get "/",
          :value   => "<4",
          :api_key => @normal_user.primary_api_key
      end
    
      use "successful GET of ratings with value less than 4"
    end
    
    context "admin API key : get / with value less than 4" do
      before do
        get "/",
          :value   => "<4",
          :api_key => @admin_user.primary_api_key
      end
    
      use "successful GET of ratings with value less than 4"
    end
    
    # - - - - - - - - - -

    context "normal API key : get / with value less than or equal to 3" do
      before do
        get "/",
          :value   => "<=3",
          :api_key => @normal_user.primary_api_key
      end
    
      use "successful GET of ratings with value less than 4"
    end
    
    context "admin API key : get / with value less than or equal to 3" do
      before do
        get "/",
          :value   => "<=3",
          :api_key => @admin_user.primary_api_key
      end
    
      use "successful GET of ratings with value less than 4"
    end
  end

end
