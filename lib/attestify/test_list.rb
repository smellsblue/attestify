module Attestify
  # Holds the tests that will be loaded for a test run.
  class TestList
    attr_reader :dir, :test_helper_file

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
      if provided_files?
        test_filters.any? { |filter| filter.run?(test_class, method) }
      else
        true
      end
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
        source_location = real_source_location(test_class, method)
        file_matches?(source_location) && line_matches?(source_location)
      end

      private

      def file_matches?(source_location)
        real_file == source_location.first
      end

      def line_matches?(source_location)
        if line
          line == source_location.last
        else
          true
        end
      end

      def real_file
        @real_file ||= File.realpath(file)
      end

      def real_source_location(test_class, method)
        test_class.instance_method(method).source_location.tap do |result|
          result[0] = File.realpath(result[0])
        end
      end
    end
  end
end
