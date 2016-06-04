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
      @test_files ||=
        begin
          if provided_files?
            @provided_files.map { |path| all_test_files_for(path) }.flatten.compact
          else
            all_test_files_for(dir) || []
          end
        end
    end

    def run?(test_class, method)
      if provided_files?
        real_test_files.any? { |file| file == real_test_file(test_class, method) }
      else
        true
      end
    end

    private

    def real_test_files
      @real_test_files ||= test_files.map { |file| File.realpath(file) }
    end

    def real_test_file(test_class, method)
      File.realpath(test_class.instance_method(method).source_location.first)
    end

    def provided_files?
      @provided_files && !@provided_files.empty?
    end

    def all_test_files_for(path)
      if File.directory?(path)
        Dir[File.join(path, "**/*_test.rb")]
      elsif File.file?(path)
        path
      end
    end
  end
end
