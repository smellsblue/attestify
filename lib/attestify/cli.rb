require "attestify"

module Attestify
  # Command Line Interface for running Attestify tests.
  class CLI
    def self.start
      Attestify::Timing.time do
        # Time the run of all tests running.
      end
    end
  end
end
