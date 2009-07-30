module RequestHelpers

  # Beware -- although caching (memoizing) is tempting:
  #
  #   @parsed_response_body ||= JSON.parse(last_response.body)
  #
  # But this is dangerous; when calling multiple REST methods,
  # the later calls would not get an updated parse.
  #
  # To allow for this, we'd need to be able to clear the cached
  # result -- that seems like more trouble than it is worth.
  #
  def parsed_response_body
    JSON.parse(last_response.body)
  end
  
end
