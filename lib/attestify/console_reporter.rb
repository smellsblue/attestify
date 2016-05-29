module Attestify
  # Reports results to the console.
  class ConsoleReporter
    attr_accessor :timer

    def report
      puts "Elapsed time: #{timer}"
    end
  end
end
