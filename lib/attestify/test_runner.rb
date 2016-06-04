require "attestify"

module Attestify
  # A basic test runner to run all tests.
  class TestRunner
    attr_reader :test_list, :reporter

    def initialize(test_list, reporter)
      @test_list = test_list
      @reporter = reporter
    end

    def run
      require_helper
      require_tests
      run_tests
    end

    private

    def require_helper
      require_real_file test_list.test_helper_file
    end

    def require_tests
      test_list.test_files.each { |f| require_real_file f }
    end

    # If we don't require via realpath, some relative paths will be
    # rejected as not being in Ruby's path.
    def require_real_file(file)
      return unless file
      require File.realpath(file)
    end

    def run_tests
      Attestify::Test.tests.each do |test|
        test.run(reporter, test_list)
      end
    end

    def report_tests
      reporter.report
    end
  end
end
