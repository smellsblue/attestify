# NOTE: This test is not intended to be an actual test, but instead is
# used for test/attestify/test_list_test.rb to provide a predictable
# test file with predictable test locations for some of the tests
# there. Do not modify this test without making sure those tests still
# pass.
class Attestify::ExampleTest < Attestify::Test
  def test_an_important_question
    the_question = "What do you get if you multiply six by nine?"
    assert_equal "What do you get if you multiply six by nine?", the_question
  end

  def test_an_important_answer
    assert_42 42
  end
end
