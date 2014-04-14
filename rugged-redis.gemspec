# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rugged/redis/version'

Gem::Specification.new do |spec|
  spec.name          = "rugged-redis"
  spec.version       = Rugged::Redis::VERSION
  spec.authors       = ["Viktor Charypar"]
  spec.email         = ["charypar@gmail.com"]
  spec.summary       = %q{Redis storage backend for rugged}
  spec.description   = %q{Enables rugged to store bare repositories entirely in Redis}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  spec.extensions = %w[ext/rugged/redis/extconf.rb]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rake-compiler"
end
