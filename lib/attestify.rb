# :nodoc:
module Attestify
  autoload :AssertionResults, "attestify/assertion_results"
  autoload :Assertions,       "attestify/assertions"
  autoload :Autorun,          "attestify/autorun"
  autoload :CLI,              "attestify/cli"
  autoload :ColorReporter,    "attestify/color_reporter"
  autoload :Mock,             "attestify/mock"
  autoload :RakeTask,         "attestify/rake_task"
  autoload :Reporter,         "attestify/reporter"
  autoload :SkippedError,     "attestify/skipped_error"
  autoload :Test,             "attestify/test"
  autoload :TestExecutor,     "attestify/test_executor"
  autoload :TestList,         "attestify/test_list"
  autoload :TestRunner,       "attestify/test_runner"
  autoload :Timer,            "attestify/timer"
  autoload :VERSION,          "attestify/version"

  def self.root
    @root ||= File.realpath(File.expand_path("..", __dir__)).freeze
  end

  def self.disable_autorun
    @autorun_disabled = true
    @autorun.disable if @autorun
  end

  def self.autorun
    @autorun ||= Attestify::Autorun.new.tap { |a| a.enable unless @autorun_disabled }
  end
end
