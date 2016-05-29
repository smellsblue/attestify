module Attestify
  # Reports results to the console.
  class Reporter
    attr_accessor :timer

    def passed?
    end

    def report
      puts "Elapsed time: #{timer}"
    end

    def record(result)
    end
  end
end
