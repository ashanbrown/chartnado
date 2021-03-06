# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'chartnado/version'

Gem::Specification.new do |spec|
  spec.name          = "chartnado"
  spec.version       = Chartnado::VERSION
  spec.authors       = ["Andrew S. Brown"]
  spec.email         = ["andrew@dontfidget.com"]
  spec.description   = %q{Chartkick charts with extras}
  spec.summary       = %q{Chartkick charts with extras}
  spec.homepage      = "https://github.com/dontfidget/chartnado"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  spec.required_ruby_version = '>= 2.0'

  spec.add_dependency "activesupport", '>= 3'
  spec.add_dependency "chartkick", '>= 1.0'
  spec.add_dependency "chartkick-remote", '>= 1.3'
  spec.add_dependency "railties", ">= 3.1"
  spec.add_development_dependency "responders", '~> 2.0'
  spec.add_development_dependency "bundler", '~> 1.3'
  spec.add_development_dependency "rake", '~> 10.3'
  spec.add_development_dependency "rspec", '~> 3.0'
  spec.add_development_dependency "rspec-core", '~> 3.0'
  spec.add_development_dependency "rspec-mocks", '~> 3.0'
  spec.add_development_dependency "rspec-rails", '~> 3.0'
  spec.add_development_dependency "travis-lint", '~> 1.8'
  spec.add_development_dependency "codeclimate-test-reporter", '~> 0.3'
  spec.add_development_dependency "coveralls", '~> 0.3'
  # spec.add_development_dependency "rspec-html-matchers", '~> 0.6.1', '>= 0.6.1'
end
