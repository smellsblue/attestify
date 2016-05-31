require "attestify"

module Attestify
  # Command Line Interface for running Attestify tests.
  class CLI
    def initialize
      @exit_code = true
    end

    def self.start
      new.start
    end

    def reporter
      @reporter ||= Attestify::ColorReporter.new
    end

    def start
      timer = Attestify::Timer.time do
        Attestify::TestRunner.new(reporter).run
        @exit_code = 1 unless reporter.passed?
      end
    rescue => e
      @exit_code = 2
      abort("Error running tests: #{e}\n  #{e.backtrace.join("\n  ")}")
    ensure
      reporter.timer = timer
      reporter.report
      exit(@exit_code)
    end
  end
end
