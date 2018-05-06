require "attestify"

module Attestify
  # This is the base class for all Attestify tests.
  class Test
    include Attestify::Assertions

    def initialize(method)
      @_test_method = method
      @_assertions = Attestify::AssertionResults.new
    end

    def self.inherited(test_class)
      tests << test_class
    end

    def self.tests
      @tests ||= []
    end

    def self.run(reporter, filter = nil)
      runnable_methods.each do |method|
        run_one_method(self, method, reporter, filter)
      end
    end

    def self.current_test
      Thread.current[:Attestify_Test_CurrentTest]
    end

    def self.run_one_method(test_class, method, reporter, filter = nil)
      return if filter && !filter.run?(test_class, method)

      begin
        test = test_class.new(method)
        Thread.current[:Attestify_Test_CurrentTest] = test
        reporter.record test.run
      ensure
        Thread.current[:Attestify_Test_CurrentTest] = nil
      end
    end

    def self.runnable_methods
      instance_methods.select { |method| method.to_s.start_with?("test_") }
    end

    def setup; end

    def teardown; end

    def assertions
      @_assertions
    end

    def name
      "#{self.class.name}##{@_test_method}"
    end

    def assertions_total
      assertions.total
    end

    def failed_assertions_total
      assertions.failed
    end

    def passed?
      assertions.passed?
    end

    def errored?
      assertions.errored?
    end

    def failed?
      assertions.failed?
    end

    def result_code # rubocop:disable Metrics/MethodLength
      if passed?
        "."
      elsif skipped?
        "S"
      elsif errored?
        "E"
      elsif failed?
        "F"
      else
        "?"
      end
    end

    def run
      begin
        setup
        send @_test_method
      ensure
        teardown
      end
    rescue StandardError => e
      assertions.error = e
    ensure
      return self # rubocop:disable Lint/EnsureReturn
    end
  end
end
