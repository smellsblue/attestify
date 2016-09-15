require "open3"

class Attestify::AutorunTest < Attestify::Test
  def test_autorun_that_succeeds
    assert_exec_test "succeeds"
  end

  def test_autorun_that_fails
    assert_exec_test "fails", status: false
  end

  def test_autorun_where_test_helper_must_be_required_first
    assert_exec_test "test_helper_must_be_required_first"
  end

  private

  def assert_exec_test(test_name, status: true, stdout: //, stderr: /\A\z/)
    test_dir = "test/data/autorun_test"
    test_file = File.join(test_dir, "#{test_name}.rb")
    actual_stdout, actual_stderr, actual_status = Open3.capture3("ruby", "-Ilib", test_file, "-d", test_dir)
    assert_equal status, actual_status.success?
    assert_match actual_stdout, stdout
    assert_match actual_stderr, stderr
  end
end
