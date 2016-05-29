module Attestify
  # A module to report on the timing of blocks of code.
  module Timing
    module_function def time
      start_time = Time.new
      yield
    ensure
      end_time = Time.new
      duration = end_time - start_time
      puts_timing(duration)
    end

    private

    module_function def puts_timing(duration)
      if duration < 1.0
        puts format("Elapsed time: %.1f milliseconds", duration * 1000.0)
      elsif duration < 60.0
        puts format("Elapsed time: %.1f seconds", duration)
      else
        puts format("Elapsed time: %.2f minutes", duration / 60.0)
      end
    end
  end
end
