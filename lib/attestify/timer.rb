module Attestify
  # A timer for keeping track of the timing of code.
  class Timer
    attr_reader :duration, :result

    def initialize
      start_time = Time.new
      @result = yield
    ensure
      end_time = Time.new
      @duration = end_time - start_time
    end

    def self.time
      Timer.new do
        yield
      end
    end

    def to_s
      if duration < 1.0
        format("%.1f milliseconds", duration * 1000.0)
      elsif duration < 60.0
        format("%.1f seconds", duration)
      else
        format("%.2f minutes", duration / 60.0)
      end
    end
  end
end
