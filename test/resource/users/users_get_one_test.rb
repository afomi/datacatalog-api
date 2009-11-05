require File.expand_path(File.dirname(__FILE__) + '/../../test_resource_helper')

class UsersGetOneTest < RequestTestCase

  def app; DataCatalog::Users end

  before do
    @user = create_user_with_primary_key
  end
  
  after do
    @user.destroy
  end

  shared "successful GET user with :id" do
    use "return 200 Ok"
  
    test "body should have correct text" do
      assert_equal "Data Mangler", parsed_response_body["name"]
    end
  end

  context "non owner API key : get /:id" do
    before do
      get "/#{@user.id}", :api_key => @normal_user.primary_api_key
    end

    use "successful GET user with :id"
    
    doc_properties %w(name id created_at updated_at)
  end

  context "owner API key : get /:id" do
    before do
      get "/#{@user.id}", :api_key => @user.primary_api_key
    end
  
    use "successful GET user with :id"
    
    doc_properties %w(name id created_at updated_at
      email primary_api_key application_api_keys valet_api_keys
      favorites
      curator admin)
    
    test "empty list of favorites" do
      assert_equal [], parsed_response_body['favorites']
    end
  end

  context "owner API key : get /:id" do
    before do
      @sources = 5.times.map do |i|
        create_source(
          :title       => "Source #{i}",
          :url         => "http://inter.net/dataset/#{i}",
          :source_type => "dataset"
        )
      end
      @ratings = 5.times.map do |i|
        create_source_rating(
          :user_id   => @user.id,
          :source_id => @sources[i].id,
          :value     => i + 1
        )
      end
      @favorites = 3.times.map do |i|
        create_favorite(
          :user_id   => @user.id,
          :source_id => @sources[i].id
        )
      end
      get "/#{@user.id}", :api_key => @user.primary_api_key
    end
    
    after do
      @favorites.each { |x| x.destroy }
      @ratings.each { |x| x.destroy }
      @sources.each { |x| x.destroy }
    end
  
    use "successful GET user with :id"
    
    test "list of 3 favorites" do
      actual = parsed_response_body['favorites']
      assert_equal 3, actual.length
      3.times do |i|
        expected = {
          'url'          => "/sources/#{@sources[i].id}",
          'title'        => @sources[i].title,
          'slug'         => @sources[i].slug,
          'description'  => @sources[i].description,
          'user_rating'  => i + 1,
          'user_note'    => nil,
          'rating_stats' => {
            'total'   => i + 1,
            'count'   => 1,
            'average' => (i + 1) / 1.0
          },
        }
        assert_include expected, actual
      end
    end
  end


end
