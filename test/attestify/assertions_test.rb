class Attestify::AssertionsTest < Attestify::Test
  def setup
    @assertions = Object.new
    @assertions.extend(Attestify::Assertions)
  end

  def test_skip_without_message
    assert_raises Attestify::SkippedError do
      @assertions.skip
    end
  end

  def test_skip_with_message
    exception = assert_raises Attestify::SkippedError do
      @assertions.skip("A custom skip message")
    end

    assert_equal "A custom skip message", exception.message
  end
end
