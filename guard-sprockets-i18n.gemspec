# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'guard/sprockets-i18n/version'

Gem::Specification.new do |spec|
  spec.name          = "guard-sprockets-i18n"
  spec.version       = Guard::SprocketsI18nVersion::VERSION
  spec.authors       = ["Martins Polakovs"]
  spec.email         = ["martins.polakovs@gmail.com"]
  spec.summary       = %q{Write a short summary. Required.}
  spec.description   = %q{Write a longer description. Optional.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'guard', '~> 2.0'
  spec.add_dependency 'i18n'
  spec.add_dependency 'sprockets'

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
