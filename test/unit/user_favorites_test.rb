require File.expand_path(File.dirname(__FILE__) + '/../test_unit_helper')

class UserFavoritesUnitTest < ModelTestCase

  context "user with no favorites" do
    before do
      @user = create_user
    end

    test "#favorites should return []" do
      assert_equal [], @user.favorites
    end
  end

  context "user with 3 favorites" do
    before do
      @user = create_user
      @sources = 3.times.map do |i|
        create_source
      end
      @favorites = 3.times.map do |i|
        create_favorite(
          :source_id => @sources[i].id,
          :user_id   => @user.id
        )
      end
    end

    after do
      @favorites.each { |x| x.destroy }
      @sources.each { |x| x.destroy }
      @user.destroy
    end

    test "#favorites should return 3 objects" do
      assert_equal 3, @user.favorites.length
    end

    test "finding id should succeed" do
      3.times do |n|
        assert_equal @favorites[n], @user.favorites.first(:_id => @favorites[n].id)
      end
    end

    test "find with fake_id should not raise exception" do
      assert_equal nil, @user.favorites.first(:_id => get_fake_mongo_object_id)
    end

    test "find! with fake_id should raise exception" do
      assert_raise MongoMapper::DocumentNotFound do
        @user.favorites.find!(get_fake_mongo_object_id)
      end
    end
  end

end
