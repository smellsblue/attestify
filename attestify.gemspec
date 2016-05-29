# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "attestify"

Gem::Specification.new do |spec|
  spec.name          = "attestify"
  spec.version       = Attestify::VERSION
  spec.authors       = ["Mike Virata-Stone"]
  spec.email         = ["mike@virata-stone.com"]

  spec.summary       = "A new way to test your code"
  spec.description   = "A small framework for testing your code. It keeps track of assertion failures as well as " \
                       "test failures."
  spec.homepage      = "https://github.com/smellsblue/attestify"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rubocop", "0.40.0"
end
