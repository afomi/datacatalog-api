module Test
  module Unit
    module Assertions

      def assert_properties(expected, actual, message=nil)
        _wrap_assertion do
          expected.each do |property|
            m1 = build_message(message,
              "<?> expected to include\n<?>.\n",
              actual.keys, property)
            assert_block(m1) { actual.include?(property) }

            extras = actual.keys - expected 
            m2 = build_message(message,
              "<?> not expected to have these extra keys\n<?>.\n",
              actual.keys, extras)
            assert_block(m2) { extras == [] }
          end
        end
      end
      
    end
  end
end
