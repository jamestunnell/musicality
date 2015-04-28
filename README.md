# Musicality

The library is based around an abstract representation for music notation. From here, functions are built up to make composing elaborate pieces in this notation representation more manageable. Finally, music performance is supported by providing translation to common formats, like MIDI.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'musicality'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install musicality

## Basic Usage

Raw notation objects can be created like this:
```ruby
require 'musicality'
include Musicality
include Pitches
include Dynamics

single = Note.quarter(Ab4)
rest = Note.quarter
chord = Note.whole([C3,E3,G3])
part = Part.new(MP, notes:[single,rest,chord])
```

Or, a compact, string representation can be used, instead.
```ruby
Part.new(FF, notes: "/4Ab4 /4 1C3,E3,G3".to_notes)
```

Parts can be put together to make a whole musical score. The block syntax can be used for embedding parts in the score.
```ruby
require 'musicality'
include Musicality
include Meters
include Dynamics

twinkle = Score::Measured.new(TWO_FOUR, 120) do |s|
  s.parts["rhand"] = Part.new(MF) do |p|
    p.notes += ("/4C4 "*2 + "/4G4 "*2 +
                "/4A4 "*2 + "/2G4").to_notes
  end
  s.parts["lhand"] = Part.new(MF) do |p|
    p.notes += ("/2C3,E3,G3 "*2 + 
                "/2F2,A2,C3 /2C3,E3,G3").to_notes
  end
  s.program.push 0...4
end
```

To continue the above example, a score can be prepare for MIDI playback using the `Score::Measured#to_midi_seq` method.
```ruby
TEMPO_SAMPLE_RATE = 500
seq = twinkle.to_midi_seq TEMPO_SAMPLE_RATE
File.open('twinkle.mid', 'wb'){ |fout| seq.write(fout) }
```
## 

## Contributing

1. Fork it ( https://github.com/[my-github-username]/musicality/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
