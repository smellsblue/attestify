require "stringio"
require "tempfile"

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
                     "but #{clazz.inspect} is not a Class or Module"
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
                     "but #{clazz.inspect} is not a Class or Module"
        end
      end
    end

    def assert_match(matcher, object, message = nil)
      record_assert(matcher =~ object) { message || "Expected #{matcher.inspect} =~ #{object.inspect}" }
    end

    def assert_nil(object, message = nil)
      record_assert(object.nil?) { message || "Expected #{object.inspect} to be nil" }
    end

    def assert_operator(left_operand, operator, right_operand, message = nil)
      if left_operand.respond_to?(operator)
        record_assert(left_operand.send(operator, right_operand)) do
          message || "Expected #{left_operand.inspect} #{operator} #{right_operand.inspect}"
        end
      else
        record_assert(false) do
          message || "Expected #{left_operand.inspect} #{operator} #{right_operand.inspect}, " \
                     "but #{left_operand.inspect} didn't respond_to?(#{operator})"
        end
      end
    end

    def assert_predicate(object, predicate, message = nil)
      if object.respond_to?(predicate)
        record_assert(object.send(predicate)) { message || "Expected #{object.inspect} to be #{predicate}" }
      else
        record_assert(false) do
          message || "Expected #{object.inspect} to be #{predicate}, " \
                     "but #{object.inspect} didn't respond_to?(#{predicate})"
        end
      end
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

    def assert_respond_to(object, method, message = nil)
      if method.is_a?(String) || method.is_a?(Symbol)
        record_assert(object.respond_to?(method)) do
          message || "Expected #{object.inspect} to respond_to?(#{method.inspect})"
        end
      else
        record_assert(false) do
          message || "Expected #{object.inspect} to respond_to?(#{method.inspect}), " \
                     "but #{method.inspect} is not a String or Symbol"
        end
      end
    end

    def assert_same(expected, actual, message = nil)
      record_assert(expected.equal?(actual)) { message || "Expected #{expected.inspect} is equal?(#{actual.inspect})" }
    end

    def assert_42(expected, message = nil) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/LineLength, Metrics/MethodLength, Metrics/PerceivedComplexity
      record_assert(
        if expected.is_a?(Numeric)
          expected == 42
        elsif expected.is_a?(String)
          expected == "42" || expected.casecmp("forty-two") == 0
        elsif expected.respond_to?("42?")
          expected.send("42?")
        elsif expected.respond_to?(:forty_two?)
          expected.forty_two?
        end
      ) do
        message || "Answer to the Ultimate Question of Life, The Universe, and Everything is Incorrect"
      end
    end

    def capture_io # rubocop:disable Metrics/MethodLength
      original_out = $stdout
      original_err = $stderr
      out = StringIO.new
      err = StringIO.new
      $stdout = out
      $stderr = err
      Object.send :remove_const, :STDOUT
      Object.send :remove_const, :STDERR
      Object.const_set :STDOUT, out
      Object.const_set :STDERR, err
      yield
      [out.string, err.string]
    ensure
      $stdout = original_out
      $stderr = original_err
      Object.send :remove_const, :STDOUT
      Object.send :remove_const, :STDERR
      Object.const_set :STDOUT, original_out
      Object.const_set :STDERR, original_err
    end

    def capture_subprocess_io # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      original_out = STDOUT.dup
      original_err = STDERR.dup
      out = Tempfile.new("attestify.out")
      err = Tempfile.new("attestify.err")
      STDOUT.reopen(out.path, "w")
      STDERR.reopen(err.path, "w")
      yield
      out.rewind
      err.rewind
      [out.read, err.read]
    ensure
      STDOUT.reopen(original_out)
      STDERR.reopen(original_err)
      out.close
      err.close
      out.unlink
      err.unlink
    end

    def flunk(message = nil)
      record_assert(false) { message || "Flunked assertion." }
    end

    def pass(_message = nil)
      record_assert(true)
    end

    def refute(value, message = nil)
      record_assert(!value) { message || "Failed refutation." }
    end

    def refute_empty(object, message = nil)
      if object.respond_to?(:empty?)
        record_assert(!object.empty?) { message || "Expected #{object.inspect} to not be empty" }
      else
        pass
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
        pass
      end
    end

    def refute_instance_of(clazz, object, message = nil)
      if clazz.is_a?(Module)
        record_assert(!object.instance_of?(clazz)) do
          message || "Expected #{object.inspect} to not be an instance_of?(#{clazz.inspect})"
        end
      else
        pass
      end
    end

    def refute_kind_of(clazz, object, message = nil)
      if clazz.is_a?(Module)
        record_assert(!object.is_a?(clazz)) do
          message || "Expected #{object.inspect} to not be a kind_of?(#{clazz.inspect})"
        end
      else
        pass
      end
    end

    def refute_match(matcher, object, message = nil)
      record_assert(!(matcher =~ object)) { message || "Expected not #{matcher.inspect} =~ #{object.inspect}" }
    end

    def refute_nil(object, message = nil)
      record_assert(!object.nil?) { message || "Expected #{object.inspect} to not be nil" }
    end

    def refute_operator(left_operand, operator, right_operand, message = nil)
      if left_operand.respond_to?(operator)
        record_assert(!left_operand.send(operator, right_operand)) do
          message || "Expected not #{left_operand.inspect} #{operator} #{right_operand.inspect}"
        end
      else
        pass
      end
    end

    def refute_predicate(object, predicate, message = nil)
      if object.respond_to?(predicate)
        record_assert(!object.send(predicate)) { message || "Expected not #{object.inspect} #{predicate}" }
      else
        pass
      end
    end

    def refute_respond_to(object, method, message = nil)
      if method.is_a?(String) || method.is_a?(Symbol)
        record_assert(!object.respond_to?(method)) do
          message || "Expected #{object.inspect} to not respond_to?(#{method.inspect})"
        end
      else
        pass
      end
    end

    def refute_same(expected, actual, message = nil)
      record_assert(!expected.equal?(actual)) do
        message || "Expected #{expected.inspect} is not equal?(#{actual.inspect})"
      end
    end

    def refute_42(_expected, _message = nil)
      record_assert(false) do
        "You should never refute that The Answer to the Ultimate Question of Life, The Universe, and Everything is 42"
      end
    end

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
