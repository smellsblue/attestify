class Attestify::TestTest < Attestify::Test
  def test_a_test_with_a_failed_assertion
    test_class = Class.new(MockTest) do
      def test_with_failed_assertion
        assert false
      end
    end

    test = test_class.new(:test_with_failed_assertion)
    test.run
    refute test.passed?
    assert_equal 1, test.assertions.failed
    assert_equal 0, test.assertions.errored
    assert_equal 0, test.assertions.passed
    assert_equal 1, test.assertions.total
  end

  def test_a_test_with_a_raised_exception
    test_class = Class.new(MockTest) do
      def test_with_raised_exception
        raise "An error"
      end
    end

    test = test_class.new(:test_with_raised_exception)
    test.run
    refute test.passed?
    assert_equal 0, test.assertions.failed
    assert_equal 1, test.assertions.errored
    assert_equal 0, test.assertions.passed
    assert_equal 0, test.assertions.total
  end

  def test_a_test_with_no_failures
    test_class = Class.new(MockTest) do
      def test_with_no_failures
        assert true
      end
    end

    test = test_class.new(:test_with_no_failures)
    test.run
    assert test.passed?
    assert_equal 0, test.assertions.failed
    assert_equal 0, test.assertions.errored
    assert_equal 1, test.assertions.passed
    assert_equal 1, test.assertions.total
  end

  def test_a_test_with_multiple_failed_assertions
    test_class = Class.new(MockTest) do
      def test_with_multiple_failures
        assert false
        assert false
      end
    end

    test = test_class.new(:test_with_multiple_failures)
    test.run
    refute test.passed?
    assert_equal 2, test.assertions.failed
    assert_equal 0, test.assertions.errored
    assert_equal 0, test.assertions.passed
    assert_equal 2, test.assertions.total
  end

  def test_a_test_with_mixed_failed_and_passed_assertions
    test_class = Class.new(MockTest) do
      def test_with_mixed_passes_and_failures
        assert false
        assert true
        assert false
        assert true
      end
    end

    test = test_class.new(:test_with_mixed_passes_and_failures)
    test.run
    refute test.passed?
    assert_equal 2, test.assertions.failed
    assert_equal 0, test.assertions.errored
    assert_equal 2, test.assertions.passed
    assert_equal 4, test.assertions.total
  end

  def test_a_skipped_test
    test_class = Class.new(MockTest) do
      def test_that_is_skipped
        assert false
        assert true
        skip
        assert false
        assert true
      end
    end

    test = test_class.new(:test_that_is_skipped)
    test.run
    refute test.passed?
    assert test.skipped?
    assert_equal 1, test.assertions.failed
    assert_equal 0, test.assertions.errored
    assert_equal 1, test.assertions.passed
    assert_equal 2, test.assertions.total
  end
end
