require "attestify"

module Attestify
  # Command Line Interface for running Attestify tests.
  class CLI
    def self.reporter
      @reporter ||= Attestify::ConsoleReporter.new
    end

    def self.start
      timer = Attestify::Timer.time do
        Attestify::TestRunner.new(reporter).run
      end
    ensure
      reporter.timer = timer
      reporter.report
    end
  end
end
