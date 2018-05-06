require "pathname"

module Attestify
  # Reports results to the console.
  class Reporter # rubocop:disable Metrics/ClassLength
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
      (@total_failures + @total_errors).zero?
    end

    def record(result)
      add_to_totals(result)
      @failures << result if !result.skipped? && !result.passed?
      print_result_code(result)
    end

    def report
      puts_failures
      puts_footer
    end

    private

    def add_to_totals(result)
      @total_tests += 1
      @total_assertions += result.assertions.total
      @total_failed_assertions += result.assertions.failed

      if result.skipped?
        @total_skips += 1
      elsif result.errored?
        @total_errors += 1
      elsif result.failed?
        @total_failures += 1
      end
    end

    def print_result_code(result)
      print result.result_code
    end

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
        puts_failure(failure, i + 1)
      end
    end

    def puts_failure(failure, number)
      puts
      puts_failure_header(failure, number)
      puts_failure_details(failure, number)
    end

    def puts_failure_header(failure, number)
      puts "#{number}) #{failure.name}: #{failure_assertion_totals(failure)}"
    end

    def failure_assertion_totals(failure)
      "#{failure.failed_assertions_total} out of #{failure.assertions_total} assertions failed"
    end

    def puts_failure_details(failure, number)
      failure.assertions.failure_details.each_with_index do |failure_detail, i|
        puts_failure_detail(failure_detail, number, i + 1)
      end
    end

    def puts_failure_detail(failure_detail, number, sub_number)
      puts
      puts "  #{number}.#{sub_number}) #{failure_detail.message}"
      puts "    #{failure_detail.backtrace_locations.join("\n    ")}"
    end

    def puts_footer
      puts
      puts "Finished in #{elapsed_time}, #{tests_per_second}, #{assertions_per_second}"
      puts "#{total_tests}, #{total_failures}, #{total_errors}, #{total_skips}, " \
           "#{total_assertions}, #{total_failed_assertions}"
      puts_failure_reruns unless @failures.empty?
    end

    def elapsed_time
      timer || "?"
    end

    def tests_per_second
      if timer
        format("%.1f tests/second", @total_tests.to_f / timer.duration)
      else
        "? tests/second"
      end
    end

    def assertions_per_second
      if timer
        format("%.1f assertions/second", @total_assertions.to_f / timer.duration)
      else
        "? assertions/second"
      end
    end

    def total_tests
      "#{@total_tests} tests"
    end

    def total_failures
      "#{@total_failures} failures"
    end

    def total_errors
      "#{@total_errors} errors"
    end

    def total_skips
      "#{@total_skips} skips"
    end

    def total_assertions
      "#{@total_assertions} assertions"
    end

    def total_failed_assertions
      "#{@total_failed_assertions} failed assertions"
    end

    def puts_failure_reruns
      puts
      puts "Failed tests:"
      puts

      @failures.each do |failure|
        puts_failure_rerun(failure)
      end
    end

    def puts_failure_rerun(failure)
      puts "#{rerun_test_command(failure)} #{comment(failure.name)}"
    end

    def rerun_test_command(failure)
      # TODO: Should I create a new method to get the test method...?
      test_method = failure.instance_variable_get(:@_test_method)
      source = failure.method(test_method).source_location
      source[0] = Pathname.new(File.realpath(source[0])).relative_path_from(Pathname.new(File.realpath(".")))
      "attestify #{source.join(":")}"
    end

    def comment(message)
      "# #{message}"
    end
  end
end
