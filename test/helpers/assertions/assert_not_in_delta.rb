module Test
  module Unit
    module Assertions

      def assert_not_in_delta(expected_float, actual_float, delta, message="")
        _wrap_assertion do
          arguments = {
            expected_float => "expected float",
            actual_float   => "actual float",
            delta          => "delta"
          }
          arguments.each do |float, name|
            assert_respond_to(float, :to_f,
              "The arguments must respond to to_f; the #{name} did not")
          end
          assert_operator(delta, :>=, 0.0,
            "The delta should not be negative")
          full_message = build_message(message, <<EOT, expected_float, actual_float, delta)
<?> and
<?> expected to be outside
<?> of each other.
EOT
          assert_block(full_message) do
            (expected_float.to_f - actual_float.to_f).abs > delta.to_f
          end
        end
      end
      
    end
  end
end
