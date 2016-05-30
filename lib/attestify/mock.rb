module Attestify
  # Simple class for mocking objects.
  class Mock
    def initialize(test_or_assertions)
      @assertions = test_or_assertions
      @assertions = test_or_assertions.assertions if test_or_assertions.respond_to?(:assertions)
      @expectations_hash = Hash.new { |hash, key| hash[key] = [] }
      @expectations = []
      @called_expectations = []
    end

    def expect(name, return_value, args = [], &block)
      name = name.to_sym
      expectation = Attestify::Mock::ExpectedCall.new(name, return_value, args, block)
      @expectations << expectation
      @expectations_hash[name.to_sym] << expectation
      self
    end

    def verify
      @called_expectations.each { |x| x.verify(@assertions) }
      @expectations.reject(&:called?).each { |x| x.verify(@assertions) }
    end

    def method_missing(method, *args, &block)
      expectation =
        if @expectations_hash[method].empty?
          UnexpectedCall.new(method, args, block)
        else
          @expectations_hash[method].shift
        end

      @called_expectations << expectation
      expectation.call(args, block)
    end

    # A base class for both ExpectedCall and UnexpectedCall.
    class CallExpectation
      attr_reader :name, :return_value, :args, :block, :actual_args, :actual_block

      def initialize(name, return_value, args, block)
        @called = false
        @name = name
        @return_value = return_value
        @args = args
        @block = block
      end

      def called?
        @called
      end

      def call(args, block)
        @called = true
        @actual_args = args
        @actual_block = block
        return_value
      end

      def to_s(style = :expected)
        if style == :expected
          "#{name}(#{args.map(&:inspect).join(", ")})"
        else
          with_block = " { ... }" if actual_block
          "#{name}(#{actual_args.map(&:inspect).join(", ")})#{with_block}"
        end
      end
    end

    # Contains a mock's method call expectation.
    class ExpectedCall < CallExpectation
      def call(args, block)
        result = super
        @caller_locations = caller_locations(2) unless arguments_valid?
        result
      end

      def verify(assertions)
        if !called?
          assertions.record(false, "Missing expected call to mock: #{self}", @caller_locations)
        elsif !arguments_valid?
          assertions.record(false, "Expected call to mock: #{self}, but got: #{to_s(:actual)}", @caller_locations)
        else
          assertions.record(true)
        end
      end

      private

      def arguments_valid?
        return false unless args.size == actual_args.size

        args.each_with_index do |arg, i|
          return false unless arg === actual_args[i] # rubocop:disable Style/CaseEquality
        end

        true
      end
    end

    # A method call that wasn't expected.
    class UnexpectedCall < CallExpectation
      def initialize(name, args, block)
        super(name, nil, args, block)
      end

      def call(args, block)
        @caller_locations = caller_locations(2)
        super
      end

      def verify(assertions)
        assertions.record(false, "Unexpected call to mock: #{to_s(:actual)}", @caller_locations)
      end
    end
  end
end
