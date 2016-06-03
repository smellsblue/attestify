module Attestify
  # Holds the tests that will be loaded for a test run.
  class TestList
    attr_reader :dir

    def initialize(files = nil)
      @dir = "./test"
      @provided_files = files
    end

    def test_files
      @test_files ||=
        begin
          if @provided_files
            @provided_files.select { |x| File.file?(x) }
          else
            Dir[File.join(dir, "**/*_test.rb")]
          end
        end
    end
  end
end
