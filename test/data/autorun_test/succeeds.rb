require "attestify"
Attestify.autorun

class Succeeds < Attestify::Test
  def test_passes
    assert true
  end
end
