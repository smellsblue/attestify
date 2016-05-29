require "attestify"

module Attestify
  # This is the base class for all Attestify tests.
  class Test
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

    def self.run(reporter)
      runnable_methods.each do |method|
        run_one_method(self, method, reporter)
      end
    end

    def self.run_one_method(test_class, method, reporter)
      reporter.record test_class.new(method).run
    end

    def self.runnable_methods
      instance_methods.select { |method| method.to_s.start_with?("test_") }
    end

    def setup
    end

    def teardown
    end

    def assertions
      @_assertions
    end

    def name
      "#{self.class.name}##{@_test_method}"
    end

    def passed?
      assertions.passed?
    end

    def result_code
      if passed?
        "."
      elsif skipped?
        "S"
      elsif assertions.errored?
        "E"
      else
        "F"
      end
    end

    def skipped?
      false
    end

    def run
      begin
        setup
        send @_test_method
      ensure
        teardown
      end
    rescue => e
      assertions.error = e
    ensure
      return self # rubocop:disable Lint/EnsureReturn
    end
  end
end
