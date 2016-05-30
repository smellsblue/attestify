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
end
