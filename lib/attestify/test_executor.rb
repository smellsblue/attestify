require "attestify"

module Attestify
  # A TestExecutor is responsible for running and outputing the test
  # reports. This module expects reporter and test_list to be implemented. The
  # reporter method must return an Attestify::Reporter, while test_list must
  # return an Attestify::TestList.
  module TestExecutor
    def start
      before_exec
      @exit_code = true
      timer = Attestify::Timer.time { run }
    rescue => e
      @exit_code = 2
      STDERR.puts("Error running tests: #{e}\n  #{e.backtrace.join("\n  ")}")
    ensure
      reporter.timer = timer
      reporter.report unless @ignore_reporting
      after_exec
    end

    private

    def run
      before_run
      Attestify::TestRunner.new(test_list, reporter).run
      @exit_code = 1 unless reporter.passed?
      after_run
    end

    attr_reader :exit_code

    def before_run
    end

    def after_run
    end

    def before_exec
    end

    def after_exec
    end

    def report?
      true
    end
  end
end
