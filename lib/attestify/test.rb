module Attestify
  # This is the base class for all Attestify tests.
  class Test
    def self.inherited(test_class)
      tests << test_class
    end

    def self.tests
      @tests ||= []
    end

    def self.run(_reporter)
    end
  end
end
