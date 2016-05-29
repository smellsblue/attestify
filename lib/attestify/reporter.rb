module Attestify
  # Reports results to the console.
  class Reporter
    attr_accessor :timer

    def initialize
      @passed = true
      @failures = []
      @total_tests = 0
      @total_assertions = 0
      @total_failures = 0
      @total_errors = 0
      @total_skips = 0
    end

    def passed?
      @passed
    end

    def record(result)
      @total_tests += 1
      @total_assertions += result.assertions.total

      if result.skipped?
        @total_skips += 1
      elsif !result.passed?
        record_failure(result)
      end

      print result.result_code
    end

    def report
      puts_failures
      puts_footer
    end

    private

    def record_failure(result)
      @passed = false
      @failures << result

      if result.assertions.errored?
        @total_errors += 1
      else
        @total_failures += 1
      end
    end

    def puts_failures
      puts

      @failures.each_with_index do |failure, i|
        puts
        puts "#{i + 1}) #{failure.name}"
        puts "  #{failure.assertions.error}" if failure.assertions.error
      end
    end

    def puts_footer
      puts
      puts "Finished in #{timer}, #{tests_per_second}, #{assertions_per_second}"
      puts
      puts "#{@total_tests} tests, #{@total_assertions} assertions, " \
           "#{@total_failures} failures, #{@total_errors} errors, #{@total_skips} skips"
    end

    def tests_per_second
      format("%.1f tests/second", @total_tests.to_f / timer.duration)
    end

    def assertions_per_second
      format("%.1f assertions/second", @total_assertions.to_f / timer.duration)
    end
  end
end
