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

    def skip
      raise Attestify::SkippedError
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
