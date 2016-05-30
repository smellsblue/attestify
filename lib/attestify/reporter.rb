module Attestify
  # Reports results to the console.
  class Reporter
    attr_accessor :timer

    def initialize
      @failures = []
      @total_tests = 0
      @total_assertions = 0
      @total_failed_assertions = 0
      @total_failures = 0
      @total_errors = 0
      @total_skips = 0
    end

    def passed?
      @total_failures + @total_errors == 0
    end

    def record(result)
      @total_tests += 1
      @total_assertions += result.assertions.total
      @total_failed_assertions += result.assertions.failed

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
        puts_failure_details(failure, i + 1)
      end
    end

    def puts_failure_details(failure, number)
      failure.assertions.failure_details.each_with_index do |failure_details, i|
        puts
        puts "  #{number}.#{i + 1}) #{failure_details.message}"
        puts "    #{failure_details.backtrace_locations.join("\n    ")}"
      end
    end

    def puts_footer
      puts
      puts "Finished in #{timer}, #{tests_per_second}, #{assertions_per_second}"
      puts "#{@total_tests} tests, #{@total_failures} failures, #{@total_errors} errors, #{@total_skips} skips, " \
           "#{@total_assertions} assertions, #{@total_failed_assertions} failed assertions"
    end

    def tests_per_second
      format("%.1f tests/second", @total_tests.to_f / timer.duration)
    end

    def assertions_per_second
      format("%.1f assertions/second", @total_assertions.to_f / timer.duration)
    end
  end
end
