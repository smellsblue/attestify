require "attestify"

module Attestify
  # Command Line Interface for running Attestify tests.
  class CLI
    def self.reporter
      @reporter ||= Attestify::Reporter.new
    end

    def self.start
      timer = Attestify::Timer.time do
        Attestify::TestRunner.new(reporter).run
      end
    rescue => e
      abort("Error running tests: #{e}\n  #{e.backtrace.join("\n  ")}")
    ensure
      reporter.timer = timer
      reporter.report
    end
  end
end
