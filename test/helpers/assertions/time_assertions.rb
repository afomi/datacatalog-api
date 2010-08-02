module Test
  module Unit
    module Assertions

      TIME_GRANULARITY = 0.999 # seconds
      MONGODB_TIME_GRANULARITY = 0.001 # seconds
      JSON_TIME_GRANULARITY = 1.0 # seconds

      def assert_equal_times(expected, actual, message = nil)
        _wrap_assertion do
          expected_time = expected.class == Time ? expected : Time.parse(expected)
          actual_time = actual.class == Time ? actual : Time.parse(actual)
          full_message = build_message(message,
            "<?> (?) expected to be the same time as\n<?> (?).\n",
            actual, actual_time.to_f, expected, expected_time.to_f)
          assert_in_delta(expected_time.to_f, actual_time.to_f,
            TIME_GRANULARITY, full_message)
        end
      end

      # ---

      def assert_equal_mongo_times(expected, actual, message = nil)
        _wrap_assertion do
          expected_time = expected.class == Time ? expected : Time.parse(expected)
          actual_time = actual.class == Time ? actual : Time.parse(actual)
          full_message = build_message(message,
            "<?> (?) expected to be the same time as\n<?> (?).\n",
            actual, actual_time.to_f, expected, expected_time.to_f)
          assert_in_delta(expected_time.to_f, actual_time.to_f,
            MONGODB_TIME_GRANULARITY, full_message)
        end
      end

      def assert_different_mongo_times(expected, actual, message = nil)
        _wrap_assertion do
          expected_time = expected.class == Time ? expected : Time.parse(expected)
          actual_time = actual.class == Time ? actual : Time.parse(actual)
          full_message = build_message(message,
            "<?> (?) expected to be a different time than\n<?> (?).\n",
            actual, actual_time.to_f, expected, expected_time.to_f)
          assert_not_in_delta(expected_time.to_f, actual_time.to_f,
            MONGODB_TIME_GRANULARITY, full_message)
        end
      end

      # ---

      def assert_equal_json_times(expected, actual, message = nil)
        _wrap_assertion do
          expected_time = expected.class == Time ? expected : Time.parse(expected)
          actual_time = actual.class == Time ? actual : Time.parse(actual)
          full_message = build_message(message,
            "<?> (?) expected to be the same time as\n<?> (?).\n",
            actual, actual_time.to_i, expected, expected_time.to_i)
          assert_equal(expected_time.to_i, actual_time.to_i, full_message)
        end
      end

      def assert_different_json_times(expected, actual, message = nil)
        _wrap_assertion do
          expected_time = expected.class == Time ? expected : Time.parse(expected)
          actual_time = actual.class == Time ? actual : Time.parse(actual)
          full_message = build_message(message,
            "<?> (?) expected to be a different time than\n<?> (?).\n",
            actual, actual_time.to_f, expected, expected_time.to_f)
          assert_not_equal(expected_time.to_i, actual_time.to_i, full_message)
        end
      end

    end
  end
end
