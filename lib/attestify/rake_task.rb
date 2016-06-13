require "rake"
require "rake/tasklib"

module Attestify
  # Rake task to run Attestify tests.
  class RakeTask < Rake::TaskLib
    attr_reader :name

    def initialize(*args, &block)
      @name = args.shift || :test
      define(args, &block)
    end

    def run_task
      Attestify::CLI.new([]).start
    end

    private

    def define(args)
      desc "Run Attestify tests" unless Rake.application.last_description

      task name, *args do |_, task_args|
        yield(self, task_args) if block_given?
        run_task
      end
    end
  end
end
