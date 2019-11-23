# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'musicality/version'

Gem::Specification.new do |spec|
  spec.name          = "musicality"
  spec.version       = Musicality::VERSION
  spec.authors       = ["James Tunnell"]
  spec.email         = ["jamestunnell@gmail.com"]
  spec.summary       = %q{Music notation, composition, and performance}
  spec.description   = "The library is based around an abstract representation \
for music notation, including pitch, note, dynamic, score, etc. A Ruby-based \
DSL is provided to aid in composition. Scores can be converted to common \
formats, like MIDI and LilyPond. Scores can also be rendered as audio via \
SuperCollider."
  spec.homepage      = "https://github.com/jamestunnell/musicality"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", ">= 1.17"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.5"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "coveralls", '~> 0.8'

  spec.add_dependency "treetop", "~> 1.5"
  spec.add_dependency 'midilib', '~> 2.0'
  spec.add_dependency 'docopt', '~> 0.5'
  spec.add_dependency 'os', '~> 0.9'

  spec.required_ruby_version = '>= 2.0'
end
