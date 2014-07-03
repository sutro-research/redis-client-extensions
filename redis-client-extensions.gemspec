# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'redis-client-extensions/version'

Gem::Specification.new do |spec|
  spec.name          = "redis-client-extensions"
  spec.version       = RedisClientExtensions::VERSION
  spec.authors       = ["Andrew Berls"]
  spec.email         = ["andrew.berls@gmail.com"]
  spec.summary       = %q{Useful extensions to the redis-rb client library}
  spec.description   = %q{A set of core extensions to the redis-rb client library}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency 'mock_redis', '~> 0.13.2'
  spec.add_development_dependency 'redis', '~> 3.0.7'
  spec.add_development_dependency 'rspec', '~> 3.0.0'
end
