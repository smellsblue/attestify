module Attestify
  # Utility error that is raised when a test is skipped, preventing
  # further code in the test to run.
  class SkippedError < StandardError
  end
end
