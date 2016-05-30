# :nodoc:
module Attestify
  autoload :AssertionResults, "attestify/assertion_results"
  autoload :Assertions,       "attestify/assertions"
  autoload :CLI,              "attestify/cli"
  autoload :Mock,             "attestify/mock"
  autoload :Reporter,         "attestify/reporter"
  autoload :SkippedError,     "attestify/skipped_error"
  autoload :Test,             "attestify/test"
  autoload :TestRunner,       "attestify/test_runner"
  autoload :Timer,            "attestify/timer"
  autoload :VERSION,          "attestify/version"

  def self.root
    @root ||= File.realpath(File.expand_path("../..", __FILE__)).freeze
  end
end
