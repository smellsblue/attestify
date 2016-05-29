module Attestify
  # Stores the results of running assertions (and other test related
  # results).
  class AssertionResults
    attr_accessor :error
    attr_reader :passed, :failed, :total

    def initialize
      @passed = 0
      @failed = 0
      @total = 0
    end

    def record(passed)
      if passed
        @passed += 1
      else
        @failed += 1
      end

      @total += 1
    end

    def errored
      if error
        1
      else
        0
      end
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
  end
end
