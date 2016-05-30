module Attestify
  # Stores the results of running assertions (and other test related
  # results).
  class AssertionResults
    attr_reader :error, :passed, :failed, :total, :failure_details

    def initialize
      @passed = 0
      @failed = 0
      @total = 0
      @failure_details = []
    end

    def error=(exception)
      @failure_details << Attestify::AssertionResults::FailureDetail.for_error(exception)
      @error = exception
    end

    def record(passed, message = nil, backtrace_locations = nil)
      if passed
        @passed += 1
      else
        @failure_details << Attestify::AssertionResults::FailureDetail.new(message, backtrace_locations)
        @failed += 1
      end

      @total += 1
    end

    def errored
      if skipped?
        0
      elsif error
        1
      else
        0
      end
    end

    def skipped?
      error.is_a?(Attestify::SkippedError)
    end

    def errored?
      error
    end

    def failed?
      @failed > 0
    end

    def passed?
      !errored? && !failed?
    end

    # Contains details of a failure, including the message and
    # backtrace information.
    class FailureDetail
      attr_reader :message, :backtrace_locations
      ATTESTIFY_LIB = File.join(Attestify.root, "lib").freeze

      def initialize(message, backtrace_locations)
        @message = message
        @backtrace_locations = simplify_backtrace_locations(backtrace_locations)
      end

      def self.for_error(exception)
        new("#{exception.class.name}: #{exception.message}", exception.backtrace_locations)
      end

      private

      def simplify_backtrace_locations(backtrace_locations)
        result = backtrace_locations.dup
        result.pop while !result.empty? && !location_in_attestify?(result.last)
        result.pop while !result.empty? && location_in_attestify?(result.last)
        result
      rescue
        # In case of a disaster, use the original locations, otherwise
        # tests that should fail would seem to succeed.
        return backtrace_locations
      end

      def location_in_attestify?(location)
        path = File.realpath(location.absolute_path)
        return false if path.size < ATTESTIFY_LIB.size
        return false unless path[0...ATTESTIFY_LIB.size] == ATTESTIFY_LIB
        path[ATTESTIFY_LIB.size] == File::SEPARATOR
      end
    end
  end
end
