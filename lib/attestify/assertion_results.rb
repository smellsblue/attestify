module Attestify
  # Stores the results of running assertions (and other test related
  # results).
  class AssertionResults
    attr_accessor :error

    def errored?
      error
    end

    def passed?
      !error
    end
  end
end
