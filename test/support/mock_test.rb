class MockTest < Attestify::Test
  def self.inherited(_test_class)
    # Prevent this from being added to the list of tests.
  end
end
