require_relative "example_test.rb"
require_relative "example/nested_test.rb"

class Attestify::TestListTest < Attestify::Test
  def test_no_explicit_files_uses_correct_dir_and_has_correct_files
    tests = Attestify::TestList.new
    assert_same_file "./test", tests.dir
    assert_same_file "./test/test_helper.rb", tests.test_helper_file
    test_files = Dir["./test/**/*_test.rb"]
    refute_empty test_files
    assert_same_files test_files, tests.test_files
  end

  def test_no_explicit_files_doesnt_filter_tests
    tests = Attestify::TestList.new
    assert tests.run?(Attestify::ExampleTest, :test_an_important_question)
    assert tests.run?(Attestify::ExampleTest, :test_an_important_answer)
    assert tests.run?(Attestify::ExampleNestedTest, :test_something_important)
    assert tests.run?(Attestify::ExampleNestedTest, :test_something_even_more_important)
  end

  def test_exmpty_explicit_files_uses_correct_dir_and_has_correct_files
    tests = Attestify::TestList.new([])
    assert_same_file "./test", tests.dir
    assert_same_file "./test/test_helper.rb", tests.test_helper_file
    test_files = Dir["./test/**/*_test.rb"]
    refute_empty test_files
    assert_same_files test_files, tests.test_files
  end

  def test_explicit_files_doesnt_change_other_attributes
    tests = Attestify::TestList.new(["./test/some_test_file.rb"])
    assert_same_file "./test", tests.dir
    assert_same_file "./test/test_helper.rb", tests.test_helper_file
  end

  def test_explicit_but_missing_file
    tests = Attestify::TestList.new(["./test/missing_test_file.rb"])
    assert_empty tests.test_files
  end

  def test_explicit_valid_file
    tests = Attestify::TestList.new(["./test/attestify/example_test.rb"])
    assert_same_files ["./test/attestify/example_test.rb"], tests.test_files
  end

  def test_explicit_file_filters_all_but_that_file
    tests = Attestify::TestList.new(["./test/attestify/example_test.rb"])
    assert tests.run?(Attestify::ExampleTest, :test_an_important_question)
    assert tests.run?(Attestify::ExampleTest, :test_an_important_answer)
    refute tests.run?(Attestify::ExampleNestedTest, :test_something_important)
    refute tests.run?(Attestify::ExampleNestedTest, :test_something_even_more_important)
  end

  def test_explicit_valid_and_missing_files
    tests = Attestify::TestList.new(["./test/missing_test_file.rb", "./test/attestify/example_test.rb"])
    assert_same_files ["./test/attestify/example_test.rb"], tests.test_files
  end

  def test_explicit_multiple_files
    tests = Attestify::TestList.new(["./test/attestify/example_test.rb", "./test/attestify/example/nested_test.rb"])
    assert_same_files ["./test/attestify/example_test.rb", "./test/attestify/example/nested_test.rb"], tests.test_files
  end

  def test_providing_directory
    tests = Attestify::TestList.new(["./test/attestify"])
    test_files = Dir["./test/attestify/**/*_test.rb"]
    refute_empty test_files
    assert_same_files test_files, tests.test_files
  end

  def test_providing_directory_filters_files_except_in_the_directory
    tests = Attestify::TestList.new(["./test/attestify/example"])
    refute tests.run?(Attestify::ExampleTest, :test_an_important_question)
    refute tests.run?(Attestify::ExampleTest, :test_an_important_answer)
    assert tests.run?(Attestify::ExampleNestedTest, :test_something_important)
    assert tests.run?(Attestify::ExampleNestedTest, :test_something_even_more_important)
  end

  def test_providing_directory_and_files
    tests = Attestify::TestList.new(["./test/attestify/example_test.rb", "./test/attestify/example"])
    test_files = Dir["./test/attestify/example/**/*_test.rb"]
    refute_empty test_files
    test_files << "./test/attestify/example_test.rb"
    assert_same_files test_files, tests.test_files
  end

  def test_change_base_test_directory_to_missing_directory
    tests = Attestify::TestList.new(dir: "./missing_base_test_dir")
    assert_nil tests.test_helper_file
    assert_empty tests.test_files
  end

  def test_change_base_test_directory_to_another_directory
    tests = Attestify::TestList.new(dir: "./test/attestify/example")
    assert_same_file "./test/attestify/example", tests.dir
    test_files = Dir["./test/attestify/example/**/*_test.rb"]
    refute_empty test_files
    assert_same_files test_files, tests.test_files
  end

  def test_change_base_test_directory_to_another_directory_that_has_a_test_helper
    tests = Attestify::TestList.new(dir: "./test/data/test_list_test")
    assert_same_file "./test/data/test_list_test/test_helper.rb", tests.test_helper_file
  end

  def test_change_base_test_directory_to_another_directory_that_doesnt_have_test_helper
    tests = Attestify::TestList.new(dir: "./test/attestify/example")
    assert_nil tests.test_helper_file
  end

  def test_explicit_valid_file_with_line_number
    tests = Attestify::TestList.new(["./test/attestify/example_test.rb:7"])
    assert_same_files ["./test/attestify/example_test.rb"], tests.test_files
  end

  def test_explicit_missing_file_with_line_number
    tests = Attestify::TestList.new(["./test/missing_test_file.rb:7"])
    assert_empty tests.test_files
  end

  def test_explicit_file_with_exact_line_number_filters_all_but_that_file_and_the_specific_test_defined_on_it
    tests = Attestify::TestList.new(["./test/attestify/example_test.rb:7"])
    assert tests.run?(Attestify::ExampleTest, :test_an_important_question)
    refute tests.run?(Attestify::ExampleTest, :test_an_important_answer)
  end

  def test_explicit_file_with_line_number_inside_method_filters_all_but_that_file_and_the_specific_test_defined_above_it
    tests = Attestify::TestList.new(["./test/attestify/example_test.rb:9"])
    assert tests.run?(Attestify::ExampleTest, :test_an_important_question)
    refute tests.run?(Attestify::ExampleTest, :test_an_important_answer)
  end

  def test_explicit_file_with_line_number_inside_later_method_filters_all_but_that_file_and_the_specific_test_defined_above_it
    tests = Attestify::TestList.new(["./test/attestify/example_test.rb:13"])
    refute tests.run?(Attestify::ExampleTest, :test_an_important_question)
    assert tests.run?(Attestify::ExampleTest, :test_an_important_answer)
  end

  def test_explicit_file_with_line_number_between_methods_filters_all_but_that_file_and_the_specific_test_defined_above_it
    tests = Attestify::TestList.new(["./test/attestify/example_test.rb:11"])
    assert tests.run?(Attestify::ExampleTest, :test_an_important_question)
    refute tests.run?(Attestify::ExampleTest, :test_an_important_answer)
  end

  def test_explicit_file_with_line_number_above_all_methods_filters_all_methods_out
    tests = Attestify::TestList.new(["./test/attestify/example_test.rb:5"])
    refute tests.run?(Attestify::ExampleTest, :test_an_important_question)
    refute tests.run?(Attestify::ExampleTest, :test_an_important_answer)
  end

  private

  def assert_same_file(expected, actual)
    assert_equal File.realpath(expected), File.realpath(actual)
  end

  def assert_same_files(expected, actual)
    expected_real_files = expected.map { |x| File.realpath(x) }
    actual_real_files = actual.map { |x| File.realpath(x) }
    assert_equal expected_real_files.sort, actual_real_files.sort
  end
end
