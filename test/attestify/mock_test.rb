class Attestify::MockTest < Attestify::Test
  def setup
    @assertions = Attestify::AssertionResults.new
    @assert = Assertable.new(@assertions)
    @mock = Attestify::Mock.new(@assertions)
  end

  def test_mock_not_called_records_failure_with_backtrace
    assertions = Object.new
    context = self

    assertions.define_singleton_method(:record) do |value, message, backtrace|
      context.refute value
      context.assert_equal "Missing expected call to mock: some_method()", message
      context.assert_instance_of Array, backtrace
    end

    mock = Attestify::Mock.new(assertions)
    mock.expect(:some_method, true)
    mock.verify
  end

  def test_mock_with_no_argument_uses_current_test
    mock = Attestify::Mock.new
    mock.expect(:some_method, true)
    assert mock.some_method
    mock.verify
  end

  def test_mock_respond_to_works
    @mock.expect(:one_method, true)
    @mock.expect(:two_method, true)
    assert @mock.respond_to?(:one_method)
    assert @mock.respond_to?("one_method")
    assert @mock.respond_to?(:two_method)
    assert @mock.respond_to?("two_method")
    refute @mock.respond_to?(:three_method)
    refute @mock.respond_to?("three_method")
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

  def test_mock_with_too_many_arguments
    @mock.expect(:example, true, [42, 4])
    @mock.example(42, 4, 2)
    @mock.verify
    assert_equal 0, @assertions.passed
    assert_equal 1, @assertions.failed
  end

  def test_mock_with_not_enough_arguments
    @mock.expect(:example, true, [42, 4])
    @mock.example(42)
    @mock.verify
    assert_equal 0, @assertions.passed
    assert_equal 1, @assertions.failed
  end

  def test_mock_with_arguments_that_match
    @mock.expect(:example, true, [42, 4])
    @mock.example(42, 4)
    @mock.verify
    assert_equal 1, @assertions.passed
    assert_equal 0, @assertions.failed
  end

  def test_mock_with_arguments_that_dont_match
    @mock.expect(:example, true, [42, 4])
    @mock.example(42, 5)
    @mock.verify
    assert_equal 0, @assertions.passed
    assert_equal 1, @assertions.failed
  end

  def test_mock_with_class_arguments_that_match
    @mock.expect(:example, true, [Integer, String])
    @mock.example(42, "4")
    @mock.verify
    assert_equal 1, @assertions.passed
    assert_equal 0, @assertions.failed
  end

  def test_mock_with_class_arguments_that_dont_match
    @mock.expect(:example, true, [Integer, String])
    @mock.example("42", 4)
    @mock.verify
    assert_equal 0, @assertions.passed
    assert_equal 1, @assertions.failed
  end

  def test_expect_with_block_that_does_nothing
    called = false
    @mock.expect(:example, true, [Integer, String]) { called = true }
    @mock.example(42, "4")
    assert called
  end

  def test_expect_with_block_that_asserts_on_arguments
    @mock.expect(:example, :answer, [Integer, String]) do |x, y|
      @assert.assert_equal 42, x
      @assert.assert_equal "4", y
    end

    assert_equal :answer, @mock.example(42, "4")
    assert_equal 2, @assertions.passed
    assert_equal 0, @assertions.failed
  end

  def test_expect_with_block_that_asserts_on_arguments_and_fails
    @mock.expect(:example, :answer, [Integer, String]) do |x, y|
      @assert.assert_equal 42, x
      @assert.assert_equal "4", y
    end

    assert_equal :answer, @mock.example("42", 4)
    assert_equal 0, @assertions.passed
    assert_equal 2, @assertions.failed
  end

  def test_expect_with_block_that_yields_and_succeeds
    @mock.expect(:example, :answer) do |&block|
      @assert.assert_equal 42, block.call
    end

    assert_equal(:answer, @mock.example { 42 })
    assert_equal 1, @assertions.passed
    assert_equal 0, @assertions.failed
  end

  def test_expect_with_block_that_yields_and_fails
    @mock.expect(:example, :answer) do |&block|
      @assert.assert_equal 42, block.call
    end

    assert_equal(:answer, @mock.example { "42" })
    assert_equal 0, @assertions.passed
    assert_equal 1, @assertions.failed
  end
end
