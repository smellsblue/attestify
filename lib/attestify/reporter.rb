module Attestify
  # Reports results to the console.
  class Reporter
    attr_accessor :timer

    def initialize
      @passed = true
      @failures = []
    end

    def passed?
      @passed
    end

    def record(result)
      if !result.passed? && !result.skipped?
        @passed = false
        @failures << result
      end

      print result.result_code
    end

    def report
      puts

      @failures.each_with_index do |failure, i|
        puts
        puts "#{i + 1}) #{failure.name}"
        puts "  #{failure.assertions.error}" if failure.assertions.error
      end

      puts
      puts "Elapsed time: #{timer}"
    end
  end
end
