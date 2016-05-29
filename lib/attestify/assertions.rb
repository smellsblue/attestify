module Attestify
  # Assertion methods that record assertion results via the
  # `assertions` method. The `assertions` method is expected to return
  # an Attestify::AssertionResults.
  module Assertions
    def assert(value)
      record_assert(value)
    end

    def refute(value)
      record_assert(!value)
    end

    def assert_equal(expected, actual)
      record_assert(expected == actual)
    end

    def refute_equal(expected, actual)
      record_assert(expected != actual)
    end

    private

    def record_assert(passed)
      assertions.record(passed)
    end
  end
end
