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
  spec.description   = %q{The library is based around an abstract representation for music notation. \
                          From here, functions are built up to make composing elaborate pieces in this notation representation more manageable. \
                          Finally, music performance is supported by providing translation to common formats, like MIDI. }
  spec.homepage      = "https://github.com/jamestunnell/musicality"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
