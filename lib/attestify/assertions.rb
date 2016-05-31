module Attestify
  # Assertion methods that record assertion results via the
  # `assertions` method. The `assertions` method is expected to return
  # an Attestify::AssertionResults.
  module Assertions # rubocop:disable Metrics/ModuleLength
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

    def assert_in_delta(expected, actual, delta = 0.001, message = nil)
      record_assert((expected - actual).abs < delta) do
        message || "Expected #{expected.inspect} == #{actual.inspect} within #{delta.inspect}"
      end
    end

    def assert_includes(collection, object, message = nil)
      if collection.respond_to?(:include?)
        record_assert(collection.include?(object)) do
          message || "Expected #{collection.inspect} to include?(#{object.inspect})"
        end
      else
        record_assert(false) do
          message || "Expected #{collection.inspect} to include?(#{object.inspect}), " \
                     "but it didn't respond_to(:include?)"
        end
      end
    end

    def assert_instance_of(clazz, object, message = nil)
      if clazz.is_a?(Module)
        record_assert(object.instance_of?(clazz)) do
          message || "Expected #{object.inspect} to be an instance_of?(#{clazz.inspect})"
        end
      else
        record_assert(false) do
          message || "Expected #{object.inspect} to be an instance_of?(#{clazz.inspect}), " \
                     "but #{clazz.inspect} is not a class or module"
        end
      end
    end

    def assert_kind_of(clazz, object, message = nil)
      if clazz.is_a?(Module)
        record_assert(object.is_a?(clazz)) do
          message || "Expected #{object.inspect} to be a kind_of?(#{clazz.inspect})"
        end
      else
        record_assert(false) do
          message || "Expected #{object.inspect} to be a kind_of?(#{clazz.inspect}), " \
                     "but #{clazz.inspect} is not a class or module"
        end
      end
    end

    def assert_match(matcher, object, message = nil)
      record_assert(matcher =~ object) { message || "Expected #{matcher.inspect} =~ #{object.inspect}" }
    end

    def assert_nil(object, message = nil)
      record_assert(object.nil?) { message || "Expected #{object.inspect} to be nil" }
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

    def refute_in_delta(expected, actual, delta = 0.001, message = nil)
      record_assert((expected - actual).abs >= delta) do
        message || "Expected #{expected.inspect} != #{actual.inspect} within #{delta.inspect}"
      end
    end

    def refute_includes(collection, object, message = nil)
      if collection.respond_to?(:include?)
        record_assert(!collection.include?(object)) do
          message || "Expected #{collection.inspect} to not include?(#{object.inspect})"
        end
      else
        record_assert(true)
      end
    end

    def refute_instance_of(clazz, object, message = nil)
      if clazz.is_a?(Module)
        record_assert(!object.instance_of?(clazz)) do
          message || "Expected #{object.inspect} to not be an instance_of?(#{clazz.inspect})"
        end
      else
        record_assert(true)
      end
    end

    def refute_kind_of(clazz, object, message = nil)
      if clazz.is_a?(Module)
        record_assert(!object.is_a?(clazz)) do
          message || "Expected #{object.inspect} to not be a kind_of?(#{clazz.inspect})"
        end
      else
        record_assert(true)
      end
    end

    def refute_match(matcher, object, message = nil)
      record_assert(!(matcher =~ object)) { message || "Expected not #{matcher.inspect} =~ #{object.inspect}" }
    end

    def refute_nil(object, message = nil)
      record_assert(!object.nil?) { message || "Expected #{object.inspect} to not be nil" }
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
