module Test
  module Unit
    module Assertions

      def assert_equal_times(string_1, string_2)
        t1 = Time.parse(string_1)
        t2 = Time.parse(string_2)
        assert_in_delta(t1.to_f, t2.to_f, 0.001)
      end

      def assert_different_times(string_1, string_2)
        t1 = Time.parse(string_1)
        t2 = Time.parse(string_2)
        assert_not_in_delta(t1.to_f, t2.to_f, 0.001)
      end

    end
  end
end
