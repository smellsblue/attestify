module Attestify
  module Assertions
    # A helper class for Attestify::Assertions#assert_output.
    class OutputAssertion
      def initialize(expected_stdout, expected_stderr, stdout, stderr)
        @expected_stdout = expected_stdout
        @expected_stderr = expected_stderr
        @stdout = stdout
        @stderr = stderr
      end

      def assert
        assert_stdout && assert_stderr
      end

      def message
        messages = [stdout_message, stderr_message]
        "Expected #{messages.compact.join(", and ")}"
      end

      private

      def assert_stdout
        assert_output(@expected_stdout, @stdout)
      end

      def assert_stderr
        assert_output(@expected_stderr, @stderr)
      end

      def assert_output(expected, actual)
        return true unless expected

        if expected.is_a?(String)
          expected == actual
        else
          actual =~ expected
        end
      end

      def stdout_message
        output_message("$stdout", @expected_stdout, @stdout)
      end

      def stderr_message
        output_message("$stderr", @expected_stderr, @stderr)
      end

      def output_message(label, expected, actual)
        return nil unless expected

        if expected.is_a?(String)
          "#{label}: #{expected.inspect} == #{actual.inspect}"
        else
          "#{label}: #{actual.inspect} =~ #{expected.inspect}"
        end
      end
    end
  end
end
