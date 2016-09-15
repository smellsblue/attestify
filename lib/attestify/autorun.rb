require "attestify"
require "optparse"

module Attestify
  # Supports autorun mode, where all tests defined will get run.
  class Autorun
    include Attestify::TestExecutor

    def initialize(args = ARGV)
      @args = args
    end

    def test_list
      @test_list ||= Attestify::Autorun::TestList.new(dir: options[:directory])
    end

    def reporter
      @reporter ||=
        if options[:color]
          Attestify::ColorReporter.new
        else
          Attestify::Reporter.new
        end
    end

    def enable
      parse_options
      require_helper
      at_exit { start }
    end

    private

    def parse_options
      option_parser.parse!(@args)
    end

    def require_helper
      return unless test_list.test_helper_file
      require File.realpath(test_list.test_helper_file)
    end

    def options
      @options ||= {
        color: true
      }
    end

    def option_parser # rubocop:disable Metrics/MethodLength
      @option_parser ||= OptionParser.new do |opts|
        opts.on("-d", "--directory [DIR]", "Run the tests as if from the provided DIR") do |dir|
          options[:directory] = dir
        end

        opts.on("-c", "--color", "Run with color") do
          options[:color] = true
        end

        opts.on("-C", "--no-color", "Run without color") do
          options[:color] = false
        end
      end
    end

    def after_exec
      exit(exit_code)
    end

    # A TestList to support auto-running a test.
    class TestList < Attestify::TestList
      def test_files
        []
      end

      def run?(_test_class, _method)
        true
      end
    end
  end
end
