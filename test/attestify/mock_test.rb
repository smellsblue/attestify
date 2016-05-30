class Attestify::MockTest < Attestify::Test
  def setup
    @assertions = Attestify::AssertionResults.new
    @mock = Attestify::Mock.new(@assertions)
  end

  def test_mock_not_verified
    @mock.expect(:not_called, true)
    @mock.expect(:called, true)
    @mock.called
    assert_equal 0, @assertions.passed
    assert_equal 0, @assertions.failed
  end

  def test_mock_not_being_called
    @mock.expect(:not_called, true)
    @mock.verify
    assert_equal 0, @assertions.passed
    assert_equal 1, @assertions.failed
  end

  def test_mock_called_too_much
    @mock.expect(:called_too_much, true)
    @mock.expect(:called_too_much, 42)
    assert_equal true, @mock.called_too_much
    assert_equal 42, @mock.called_too_much
    assert_equal nil, @mock.called_too_much
    @mock.verify
    assert_equal 2, @assertions.passed
    assert_equal 1, @assertions.failed
  end

  def test_mock_called_with_unexpected_method
    assert_equal nil, @mock.unexpected_method
    @mock.verify
    assert_equal 0, @assertions.passed
    assert_equal 1, @assertions.failed
  end

  def test_mock_with_class_arguments_that_match
    skip
  end

  def test_mock_with_class_arguments_that_dont_match
    skip
  end

  def test_expect_with_block_that_does_nothing
    skip
  end

  def test_expect_with_block_that_asserts_on_arguments
    skip
  end
end
