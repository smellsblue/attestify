# NOTE: This test is not intended to be an actual test, but instead is
# used for test/attestify/test_list_test.rb to provide a predictable
# test file with predictable test locations for some of the tests
# there. Do not modify this test without making sure those tests still
# pass.
class Attestify::ExampleNestedTest < Attestify::Test
  def test_something_important
    assert true
  end

  def test_something_even_more_important
    the_answer = 42
    assert_equal 42, the_answer
  end
end
