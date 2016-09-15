require "open3"

class Attestify::AutorunTest < Attestify::Test
  TEST_DIR = "test/data/autorun_test".freeze

  def test_autorun_that_succeeds
    assert_exec_test "succeeds"
  end

  def test_autorun_that_fails
    assert_exec_test "fails", status: false
  end

  def test_autorun_where_test_helper_must_be_required_first
    assert_exec_test "test_helper_must_be_required_first"
  end

  def test_using_attestify_command_with_autorun_only_runs_tests_once
    assert_exec_test_via_attestify "succeeds"
  end

  def test_using_attestify_command_with_autorun_only_runs_tests_once_with_failed_tests
    assert_exec_test_via_attestify "fails", status: false
  end

  private

  def assert_exec_test(test_name, status: true, stdout: //, stderr: /\A\z/)
    test_file = File.join(TEST_DIR, "#{test_name}.rb")
    actual_stdout, actual_stderr, actual_status = Open3.capture3("ruby", "-Ilib", test_file, "-d", TEST_DIR)
    assert_equal status, actual_status.success?
    assert_match actual_stdout, stdout
    assert_match actual_stderr, stderr
  end

  def assert_exec_test_via_attestify(test_name, status: true, stdout: //, stderr: /\A\z/)
    exec_file = "exe/attestify"
    test_file = File.join(TEST_DIR, "#{test_name}.rb")
    actual_stdout, actual_stderr, actual_status = Open3.capture3("ruby", "-Ilib", exec_file, test_file, "-d", TEST_DIR)
    assert_equal 1, actual_stdout.scan("Finished in").size
    assert_equal status, actual_status.success?
    assert_match actual_stdout, stdout
    assert_match actual_stderr, stderr
  end
end
