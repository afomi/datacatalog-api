module RequestHelpers

  def parsed_response_body
    Crack::JSON.parse(last_response.body)
  end

  def self.included(includee)
    includee.extend(ClassMethods)
  end
  
  module ClassMethods

    def doc_properties(correct)
      test "document should only have correct attributes" do
        assert_properties(correct, parsed_response_body)
      end
    end

    def docs_properties(correct)
      test "documents should only have correct attributes" do
        parsed_response_body.each do |parsed|
          assert_properties(correct, parsed)
        end
      end
    end
    
    def members_properties(correct)
      test "document members should only have correct attributes" do
        parsed_response_body['members'].each do |parsed|
          assert_properties(correct, parsed)
        end
      end
    end

  end

end
