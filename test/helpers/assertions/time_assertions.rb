module Test
  module Unit
    module Assertions
      
      MONGODB_TIME_GRANULARITY = 0.001 # seconds

      def assert_equal_times(expected, actual, message = nil)
        _wrap_assertion do
          expected_time = Time.parse(expected)
          actual_time = Time.parse(actual)
          full_message = build_message(message,
            "<?> (?) expected to be the same time as\n<?> (?).\n",
            actual, actual_time.to_f, expected, expected_time.to_f)
          assert_in_delta(expected_time.to_f, actual_time.to_f,
            MONGODB_TIME_GRANULARITY, full_message)
        end
      end

      def assert_different_times(expected, actual, message = nil)
        _wrap_assertion do
          expected_time = Time.parse(expected)
          actual_time = Time.parse(actual)
          full_message = build_message(message,
            "<?> (?) expected to be a different time than\n<?> (?).\n",
            actual, actual_time.to_f, expected, expected_time.to_f)
          assert_not_in_delta(expected_time.to_f, actual_time.to_f,
            MONGODB_TIME_GRANULARITY, full_message)
        end
      end

    end
  end
end
