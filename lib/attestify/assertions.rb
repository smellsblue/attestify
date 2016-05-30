module Attestify
  # Assertion methods that record assertion results via the
  # `assertions` method. The `assertions` method is expected to return
  # an Attestify::AssertionResults.
  module Assertions
    def assert(value, message = nil)
      record_assert(value) { message || "Failed assertion." }
    end

    def assert_empty(object, message = nil)
      if object.respond_to?(:empty?)
        record_assert(object.empty?) { message || "Expected #{object.inspect} to be empty" }
      else
        record_assert(false) { message || "Expected #{object.inspect} to be empty, but it didn't respond_to(:empty?)" }
      end
    end

    def assert_equal(expected, actual, message = nil)
      record_assert(expected == actual) { message || "Expected #{expected.inspect} == #{actual.inspect}" }
    end

    def assert_raises(*exceptions)
      message = exceptions.pop if exceptions.last.is_a?(String)
      exceptions = [StandardError] if exceptions.empty?
      yield
      record_assert(false) { message || "Expected one of: #{exceptions.inspect} to be raised, but nothing was raised" }
      return nil
    rescue => e
      record_assert(exceptions.any? { |x| e.is_a?(x) }) do
        message || "Expected one of: #{exceptions.inspect} to be raised, but instead got: #{e.class.name}"
      end

      return e
    end

    def refute(value, message = nil)
      record_assert(!value) { message || "Failed refutation." }
    end

    def refute_empty(object, message = nil)
      if object.respond_to?(:empty?)
        record_assert(!object.empty?) { message || "Expected #{object.inspect} to not be empty" }
      else
        record_assert(true)
      end
    end

    def refute_equal(expected, actual, message = nil)
      record_assert(expected != actual) { message || "Expected #{expected.inspect} != #{actual.inspect}" }
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
