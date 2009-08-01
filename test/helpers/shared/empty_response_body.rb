module EmptyResponseBody

  def self.included(mod)
    mod.test "should return []" do
      assert_equal [], parsed_response_body
    end
  end

end
