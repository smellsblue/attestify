require "attestify"
Attestify.autorun

class TestHelperMustBeRequired < Attestify::Test
  include ArbitraryHelper

  def test_passes
    assert true
  end
end
