module Attestify
  # Holds the tests that will be loaded for a test run.
  class TestList
    attr_reader :dir

    def initialize(files = nil, dir: nil)
      @dir = dir || "./test"
      @provided_files = files
    end

    def test_helper_file
      @test_helper_file_path ||= File.join(dir, "test_helper.rb")
      @test_helper_file_path if File.file?(@test_helper_file_path)
    end

    def test_files
      @test_files ||= test_filters.map(&:file)
    end

    def run?(test_class, method)
      test_filters.any? { |filter| filter.run?(test_class, method) }
    end

    private

    def test_filters
      @test_filters ||=
        begin
          if provided_files?
            @provided_files.map { |path| all_file_filters_for(path) }.flatten.compact
          else
            all_file_filters_for(dir) || []
          end
        end
    end

    def provided_files?
      @provided_files && !@provided_files.empty?
    end

    def all_file_filters_for(path)
      if File.directory?(path)
        Dir[File.join(path, "**/*_test.rb")].map { |file| Attestify::TestList::FileFilter.new(file) }
      elsif File.file?(path)
        Attestify::TestList::FileFilter.new(path)
      elsif path =~ /:\d+\z/
        Attestify::TestList::FileFilter.with_line(path)
      end
    end

    # Filters tests that aren't defined in the provided file. If a
    # line is provided, then only the test defined above that line
    # will not be filtered.
    class FileFilter
      attr_reader :file, :line

      def initialize(file, line = nil)
        @file = file
        @line = line
      end

      def self.with_line(path_with_line)
        match = /\A(.*):(\d+)\z/.match(path_with_line)
        return unless File.file?(match[1])
        new(match[1], match[2].to_i)
      end

      def run?(test_class, method)
        file_matches?(test_class, method) && line_matches?(test_class, method)
      end

      private

      def file_matches?(test_class, method)
        real_file == Attestify::TestList::RealSourceLocationCache[test_class].real_file(method)
      end

      def line_matches?(test_class, method)
        if line
          Attestify::TestList::RealSourceLocationCache[test_class].in_method?(method, line)
        else
          true
        end
      end

      def real_file
        @real_file ||= File.realpath(file)
      end
    end

    # Helper class to keep track of source locations of methods for
    # tests.
    class TestClassSourceLocations
      def initialize(test_class)
        @test_class = test_class
      end

      def real_file(method)
        real_source_locations[method].first
      end

      def in_method?(method, line)
        method_at(line) == method
      end

      private

      def method_at(line)
        result = nil

        runnable_method_lines.each do |source_location|
          return result if source_location.last > line
          result = source_location.first
        end

        result
      end

      def runnable_methods
        @runnable_methods ||= @test_class.runnable_methods
      end

      def runnable_method_lines
        @runnable_method_lines ||= runnable_methods.map do |runnable_method|
          [runnable_method] + real_source_locations[runnable_method]
        end.sort do |a, b| # rubocop:disable Style/MultilineBlockChain
          if a != b
            a.last <=> b.last
          else
            a.first <=> b.first
          end
        end
      end

      def real_source_locations
        @real_source_locations ||= Hash.new do |hash, method|
          hash[method] = @test_class.instance_method(method).source_location.tap do |result|
            result[0] = File.realpath(result[0])
          end
        end
      end
    end

    # Helper class to cache source locations TestClassSourceLocations
    # for classes.
    class RealSourceLocationCache
      class << self
        def [](test_class)
          hash[test_class]
        end

        private

        def hash
          Thread.current[:Attestify_TestList_RealSourceLocationCache] ||= Hash.new do |hash, test_class|
            hash[test_class] = Attestify::TestList::TestClassSourceLocations.new(test_class)
          end
        end
      end
    end
  end
end
