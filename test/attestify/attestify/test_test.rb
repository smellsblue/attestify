class Attestify::TestTest < Attestify::Test
  def test_a_test_with_a_failed_assertion
    test_class = Class.new(Attestify::Test) do
      def test_with_failed_assertion
        assert false
      end
    end

    test = test_class.new(:test_with_failed_assertion)
    test.run
    assert test.failed?
    refute test.errored?
    refute test.passed?
    assert_equal 1, test.assertions.failed
    assert_equal 0, test.assertions.errored
    assert_equal 0, test.assertions.passed
  end

  def test_a_test_with_a_raised_exception
    test_class = Class.new(Attestify::Test) do
      def test_with_raised_exception
        raise "An error"
      end
    end

    test = test_class.new(:test_with_raised_exception)
    test.run
    refute test.failed?
    assert test.errored?
    refute test.passed?
    assert_equal 0, test.assertions.failed
    assert_equal 1, test.assertions.errored
    assert_equal 0, test.assertions.passed
  end

  def test_a_test_with_no_failures
    test_class = Class.new(Attestify::Test) do
      def test_with_no_failures
        assert true
      end
    end

    test = test_class.new(:test_with_no_failures)
    test.run
    refute test.failed?
    refute test.errored?
    assert test.passed?
    assert_equal 0, test.assertions.failed
    assert_equal 0, test.assertions.errored
    assert_equal 1, test.assertions.passed
  end

  def test_a_test_with_multiple_failed_assertions
    test_class = Class.new(Attestify::Test) do
      def test_with_multiple_failures
        assert false
        assert false
      end
    end

    test = test_class.new(:test_with_multiple_failures)
    test.run
    assert test.failed?
    refute test.errored?
    refute test.passed?
    assert_equal 2, test.assertions.failed
    assert_equal 0, test.assertions.errored
    assert_equal 0, test.assertions.passed
  end
end
