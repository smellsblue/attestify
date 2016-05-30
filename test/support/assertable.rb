class Assertable
  include Attestify::Assertions
  attr_reader :assertions

  def initialize(assertion_results)
    @assertions = assertion_results
  end
end
