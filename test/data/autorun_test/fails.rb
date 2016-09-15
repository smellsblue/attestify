require "attestify"
Attestify.autorun

class Fails < Attestify::Test
  def test_fails
    assert false
  end
end
