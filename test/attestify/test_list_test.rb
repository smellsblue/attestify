class Attestify::TestListTest < Attestify::Test
  def test_no_explicit_files_uses_correct_dir_and_has_correct_files
    tests = Attestify::TestList.new
    assert_same_file "./test", tests.dir
    test_files = Dir["./test/**/*_test.rb"]
    refute_empty test_files
    assert_same_files test_files, tests.test_files
  end

  def test_explicit_but_missing_file
    tests = Attestify::TestList.new(["./test/missing_test_file.rb"])
    assert_same_file "./test", tests.dir
    assert_empty tests.test_files
  end

  def test_explicit_valid_file
    tests = Attestify::TestList.new(["./test/attestify/assertions_test.rb"])
    assert_same_file "./test", tests.dir
    assert_same_files ["./test/attestify/assertions_test.rb"], tests.test_files
  end

  def test_explicit_valid_and_missing_files
    tests = Attestify::TestList.new(["./test/missing_test_file.rb", "./test/attestify/assertions_test.rb"])
    assert_same_file "./test", tests.dir
    assert_same_files ["./test/attestify/assertions_test.rb"], tests.test_files
  end

  def test_explicit_multiple_files
    tests = Attestify::TestList.new(["./test/attestify/assertions_test.rb", "./test/attestify/test_test.rb"])
    assert_same_file "./test", tests.dir
    assert_same_files ["./test/attestify/assertions_test.rb", "./test/attestify/test_test.rb"], tests.test_files
  end

  def test_providing_directory
    tests = Attestify::TestList.new(["./test/attestify"])
    assert_same_file "./test", tests.dir
    test_files = Dir["./test/attestify/**/*_test.rb"]
    refute_empty test_files
    assert_same_files test_files, tests.test_files
  end

  def test_providing_directory_and_files
    tests = Attestify::TestList.new(["./test/attestify/assertions_test.rb", "./test/attestify/example"])
    assert_same_file "./test", tests.dir
    test_files = Dir["./test/attestify/example/**/*_test.rb"]
    refute_empty test_files
    test_files << "./test/attestify/assertions_test.rb"
    assert_same_files test_files, tests.test_files
  end

  def test_change_base_test_directory_to_missing_directory
    skip "It should be an empty set of files"
  end

  def test_change_base_test_directory_to_another_directory
    skip "It should contain those tests"
  end

  def test_change_base_test_directory_to_another_directory_that_doesnt_have_test_helper
    skip "It should have a nil test helper file"
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
