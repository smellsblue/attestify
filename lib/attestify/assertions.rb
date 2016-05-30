module Attestify
  # Assertion methods that record assertion results via the
  # `assertions` method. The `assertions` method is expected to return
  # an Attestify::AssertionResults.
  module Assertions
    def assert(value)
      record_assert(value) { "Failed assertion." }
    end

    def refute(value)
      record_assert(!value) { "Failed refutation." }
    end

    def assert_equal(expected, actual)
      record_assert(expected == actual) { "Expected #{expected.inspect} == #{actual.inspect}" }
    end

    def refute_equal(expected, actual)
      record_assert(expected != actual) { "Expected #{expected.inspect} != #{actual.inspect}" }
    end

    def assert_raises(*exceptions)
      yield
      record_assert(false) { "Expected one of: #{exceptions.inspect} to be raised, but nothing was raised" }
      return nil
    rescue => e
      record_assert(exceptions.any? { |x| e.is_a?(x) }) do
        "Expected one of: #{exceptions.inspect} to be raised, but instead got: #{e.class.name}"
      end
      return e
    end

    # TODO: Maybe implement refute_raises?

    def skip(message = "Skipped this test")
      raise Attestify::SkippedError, message
    end

    def skipped?
      assertions.skipped?
    end

    private

    def record_assert(passed)
      if passed
        assertions.record(passed)
      else
        assertions.record(passed, yield, caller_locations(2))
      end
    end
  end
end
