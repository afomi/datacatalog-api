get '/status' do
  {
    "authentication_status" => "anonymous"
  }.to_json
end

# account_status ... user account is:
#
#     good       ... in good standing
#   throttled    ... throttled for some length of time
# 
# get '/status' do
#   {
#     "authentication_status" => "anonymous",
#     "account_status"        => "good"
#   }.to_json
# end

# test "body has correct authentication status" do
#   assert_equal "anonymous", parsed_response_body["authentication_status"]
# end
# 
# test "body has correct authentication note" do
#   expected = "This is the only resource that can be accessed without " +
#     "an API key. Sign up for a key by doing the following."
#   assert_equal expected, parsed_response_body["authentication_note"]
# end
# 
