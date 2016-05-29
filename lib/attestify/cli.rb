require "attestify"

module Attestify
  # Command Line Interface for running Attestify tests.
  class CLI
    def self.start
      Attestify::Timing.time do
        Attestify::TestRunner.new.run
      end
    end
  end
end
