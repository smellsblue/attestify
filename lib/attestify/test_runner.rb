module Attestify
  # A basic test runner to run all tests.
  class TestRunner
    def directory
      "."
    end

    def run
      require_helper
      require_tests
      run_tests
      report_tests
    end

    def reporter
      @reporter ||= Attestify::ConsoleReporter.new
    end

    private

    # Checks if the file in the relative path exists and then yields
    # the block with the full path if so.
    def file(path)
      file = File.join(directory, path)
      yield file if File.exist?(path)
    end

    def require_helper
      file("test/test_helper.rb") { |f| require f }
    end

    def require_tests
      Dir[File.join(directory, "test/**/*_test.rb")].each { |f| require f }
    end

    def run_tests
      # TODO
    end

    def report_tests
      # TODO
    end
  end
end
