class Attestify::AssertionsTest < Attestify::Test
  def setup
    @assertions = Attestify::AssertionResults.new
    @assert = Assertable.new(@assertions)
  end

  def test_skip_without_message
    assert_raises Attestify::SkippedError do
      @assert.skip
    end
  end

  def test_skip_with_message
    exception = assert_raises Attestify::SkippedError do
      @assert.skip("A custom skip message")
    end

    assert_equal "A custom skip message", exception.message
  end

  def test_passing_assert
    @assert.assert true
    assert_equal 1, @assertions.passed
    assert_equal 0, @assertions.failed
  end

  def test_failing_assert
    @assert.assert false
    assert_equal 0, @assertions.passed
    assert_equal 1, @assertions.failed
  end

  def test_assert_with_custom_message
    @assert.assert false, "Custom message"
    assert_equal "Custom message", @assertions.failure_details.first.message
  end

  def test_passing_assert_empty
    @assert.assert_empty []
    assert_equal 1, @assertions.passed
    assert_equal 0, @assertions.failed
  end

  def test_failing_assert_empty
    @assert.assert_empty [42]
    assert_equal 0, @assertions.passed
    assert_equal 1, @assertions.failed
  end

  def test_failing_assert_empty_with_empty_not_implemented
    @assert.assert_empty Object.new
    assert_equal 0, @assertions.passed
    assert_equal 1, @assertions.failed
  end

  def test_assert_empty_with_custom_message
    @assert.assert_empty [42], "Custom message"
    assert_equal "Custom message", @assertions.failure_details.first.message
  end

  def test_passing_assert_equal
    @assert.assert_equal 42, 42
    assert_equal 1, @assertions.passed
    assert_equal 0, @assertions.failed
  end

  def test_failing_assert_equal
    @assert.assert_equal 42, "Not 42"
    assert_equal 0, @assertions.passed
    assert_equal 1, @assertions.failed
  end

  def test_assert_equal_with_custom_message
    @assert.assert_equal 42, "Not 42", "Custom message"
    assert_equal "Custom message", @assertions.failure_details.first.message
  end

  def test_passing_assert_raises
    exception = ArgumentError.new("An example error")
    result = @assert.assert_raises(ArgumentError) { raise exception }
    assert_equal exception, result
    assert_equal 1, @assertions.passed
    assert_equal 0, @assertions.failed
  end

  def test_passing_assert_raises_with_multiple_possible_exceptions
    exception = ArgumentError.new("An example error")
    result = @assert.assert_raises(NoMethodError, ArgumentError) { raise exception }
    assert_equal exception, result
    assert_equal 1, @assertions.passed
    assert_equal 0, @assertions.failed
  end

  def test_failing_assert_raises_with_nothing_raised
    result = @assert.assert_raises(ArgumentError) { }
    assert_equal nil, result
    assert_equal 0, @assertions.passed
    assert_equal 1, @assertions.failed
  end

  def test_failing_assert_raises_with_wrong_error_raised
    exception = NoMethodError.new("An example error")
    result = @assert.assert_raises(ArgumentError) { raise exception }
    assert_equal exception, result
    assert_equal 0, @assertions.passed
    assert_equal 1, @assertions.failed
  end

  def test_failing_assert_raises_with_wrong_error_raised_with_multiple_possible_exceptions
    exception = NoMethodError.new("An example error")
    result = @assert.assert_raises(ArgumentError, KeyError) { raise exception }
    assert_equal exception, result
    assert_equal 0, @assertions.passed
    assert_equal 1, @assertions.failed
  end

  def test_failing_assert_raises_with_custom_message
    @assert.assert_raises(ArgumentError, "Custom message") { raise NoMethodError, "An example error" }
    assert_equal "Custom message", @assertions.failure_details.first.message
  end

  def test_assert_raises_with_custom_message_and_multiple_possible_exceptions
    @assert.assert_raises(ArgumentError, KeyError, "Custom message") { raise NoMethodError, "An example error" }
    assert_equal "Custom message", @assertions.failure_details.first.message
  end

  def test_assert_raises_with_custom_message_and_nothing_raised
    @assert.assert_raises(ArgumentError, "Custom message") { }
    assert_equal "Custom message", @assertions.failure_details.first.message
  end

  def test_passing_refute
    @assert.refute false
    assert_equal 1, @assertions.passed
    assert_equal 0, @assertions.failed
  end

  def test_failing_refute
    @assert.refute true
    assert_equal 0, @assertions.passed
    assert_equal 1, @assertions.failed
  end

  def test_refute_with_custom_message
    @assert.refute true, "Custom message"
    assert_equal "Custom message", @assertions.failure_details.first.message
  end

  def test_passing_refute_empty
    @assert.refute_empty [42]
    assert_equal 1, @assertions.passed
    assert_equal 0, @assertions.failed
  end

  def test_passing_refute_empty_with_empty_not_implemented
    @assert.refute_empty Object.new
    assert_equal 1, @assertions.passed
    assert_equal 0, @assertions.failed
  end

  def test_failing_refute_empty
    @assert.refute_empty []
    assert_equal 0, @assertions.passed
    assert_equal 1, @assertions.failed
  end

  def test_refute_empty_with_custom_message
    @assert.refute_empty [], "Custom message"
    assert_equal "Custom message", @assertions.failure_details.first.message
  end

  def test_passing_refute_equal
    @assert.refute_equal 42, "Not 42"
    assert_equal 1, @assertions.passed
    assert_equal 0, @assertions.failed
  end

  def test_failing_refute_equal
    @assert.refute_equal 42, 42
    assert_equal 0, @assertions.passed
    assert_equal 1, @assertions.failed
  end

  def test_refute_equal_with_custom_message
    @assert.refute_equal 42, 42, "Custom message"
    assert_equal "Custom message", @assertions.failure_details.first.message
  end
end
