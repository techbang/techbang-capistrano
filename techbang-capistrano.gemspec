# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'techbang/capistrano/version'

Gem::Specification.new do |spec|
  spec.name          = "techbang-capistrano"
  spec.version       = Techbang::Capistrano::VERSION
  spec.authors       = ["Techbang"]
  spec.email         = ["tech@techbang.com.tw"]
  spec.description   = "Capistrano recipes for Techbang."
  spec.summary       = "Capistrano recipes for Techbang."
  spec.homepage      = "https://github.com/techbang/techbang-capistrano"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
