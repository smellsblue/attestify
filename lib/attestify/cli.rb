require "attestify"
require "optparse"

module Attestify
  # Command Line Interface for running Attestify tests.
  class CLI
    def initialize(args = ARGV)
      @args = args
      @exit_code = true
    end

    def self.start
      new.start
    end

    def test_list
      @test_list ||= Attestify::TestList.new(@args, dir: options[:directory])
    end

    def reporter
      @reporter ||=
        if options[:color]
          Attestify::ColorReporter.new
        else
          Attestify::Reporter.new
        end
    end

    def options
      @options ||= {
        color: true
      }
    end

    def option_parser # rubocop:disable Metrics/MethodLength
      @option_parser ||= OptionParser.new do |opts|
        opts.banner = "Usage: attestify [options] [test_files ...]"

        opts.on("-c", "--color", "Run with color") do
          options[:color] = true
        end

        opts.on("-C", "--no-color", "Run without color") do
          options[:color] = false
        end

        opts.on("-d", "--directory [DIR]", "Run the tests in the provided DIR") do |dir|
          options[:directory] = dir
        end

        opts.on("-h", "--help", "Output this help") do
          puts opts
          ignore_reporting
          exit
        end
      end
    end

    def ignore_reporting
      @ignore_reporting = true
    end

    def parse_arguments
      option_parser.parse!(@args)
    end

    def start
      timer = Attestify::Timer.time { run }
    rescue => e
      @exit_code = 2
      STDERR.puts("Error running tests: #{e}\n  #{e.backtrace.join("\n  ")}")
    ensure
      reporter.timer = timer
      reporter.report unless @ignore_reporting
      exit(@exit_code)
    end

    def run
      parse_arguments
      Attestify::TestRunner.new(test_list, reporter).run
      @exit_code = 1 unless reporter.passed?
    end
  end
end
