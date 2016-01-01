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

# convenience methods for common durations
single = Note.quarter(Ab4)
rest = Note.quarter
chord = Note.whole([C3,E3,G3])

# specific duration + articulation
note = Note.new(Rational(7,8), Bb3, articulation: Articulations::STACCATO)
puts note.to_s  # => "7/8Bb3."

# magic!
puts note.transpose(2).to_s  # => "7/8C4."

# combine notes into a part
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
include Pitches

score = Score::Tempo.new(FOUR_FOUR, 120, title: "Twinkle, Twinkle, Little Star") do |s|
  s.parts["rhand"] = Part.new(MF) do |p|
    a_notes = q(C4,C4,G4,G4,A4,A4) + h(G4) +
              q(F4,F4,E4,E4,D4,D4) + h(C4)
    b_notes = q(G4,G4,F4,F4,E4,E4) + h(D4)
    p.notes += a_notes + b_notes
  end
  
  s.parts["lhand"] = Part.new(MF) do |p|
    Cmaj = [C3,E3,G3]
    Fmaj = [F2,A2,C3]
    Gmaj = [G2,B2,D3]
    
    a_chords = h(Cmaj,Cmaj,Fmaj,Cmaj) + 
               h(Fmaj,Cmaj,Gmaj,Cmaj)
    b_chords = h(Cmaj,Fmaj,Cmaj,Gmaj)
    p.notes += a_chords + b_chords
  end
  
  s.program.push 0...4
  s.program.push 4...6
  s.program.push 4...6
  s.program.push 0...4
end
```

## MIDI Sequencing

A score can be prepared for MIDI playback by converting it to a MIDI::Sequence object (see [midilib]( https://github.com/jimm/midilib )). This can be accomplished with the `ScoreSequencer` class or `Score#to_midi_seq` method. To continue the previous example,
```ruby
TEMPO_SAMPLE_RATE = 500
seq = twinkle.to_midi_seq TEMPO_SAMPLE_RATE
File.open('twinkle.mid', 'wb'){ |f| seq.write(f) }
```

## LilyPond Engraving

A score can be prepared for engraving (fancy printing) by converting it to a string in LilyPond text format (see [lilypond.org](http://lilypond.org/)). This can be accomplished using the `ScoreEngraver` class or `Score#to_lilypond` method. Using the score from the above example,
```ruby
File.open('twinkle.ly','w'){|f| f.write(twinkle.to_lilypond) }
```


## SuperCollider Rendering

A score can be prepared for rendering (as audio) by converting it to a raw OSC binary file, used for SuperCollider non-realtime rendering (see [SuperCollider homepage](https://supercollider.github.io/)). This can be accomplished using the `SuperCollider::Conductor` class or `Score#to_osc` method. Using the score from the above example,
```ruby
twinkle.to_osc('twinkle')
```


## Score DSL

The score DSL is an internal DSL (built on Ruby) that consists of a *score* block with additional blocks inside this to add sections, notes, and tempo/meter/dynamic changes.

Here is an example of a score file.
```ruby
tempo_score Meters::FOUR_FOUR, 120 do
  title "Twinkle, Twinkle, Little Star"

  Cmaj = [C3,E3,G3]
  Fmaj = [F2,A2,C3]
  Gmaj = [G2,B2,D3]
  section "A" do
    notes(
      "rhand" => q(C4,C4,G4,G4,A4,A4) + h(G4) +
                 q(F4,F4,E4,E4,D4,D4) + h(C4),
      "lhand" => h(Cmaj,Cmaj,Fmaj,Cmaj) + 
                 h(Fmaj,Cmaj,Gmaj,Cmaj)
    )
  end

  section "B" do
    notes(
      "rhand" => q(G4,G4,F4,F4,E4,E4) + h(D4),
      "lhand" => h(Cmaj,Fmaj,Cmaj,Gmaj)
    )
  end
  repeat "B"
  repeat "A"
end
```

The above score file is processed by the `ScoreDSL.load` method, as in:
```ruby
require 'musicality'
include Musicality
include Meters
include Pitches

dsl = ScoreDSL.load 'twinkle.score'
score = dsl.score
``` 


## Musicality Projects

To create a new project for working on Muscality scores, use the `musicality` command-line executable that is installed along with the gem.

    $ musicality new my_scores

This will create a directory (or fill an existing one) with three files:
* *Gemfile* - a Bundler gem dependency file that lists the `musicality` gem
* *Rakefile* - creates rake tasks for processing score files (files with a .score extension)
* *config.yml* - customize project configuration options

Also, a *scores* subdirectory is created as the default location to keep score files.

To process score files, run rake with the desired target format. The scores will be converted into any intermediate formats as necessary. For example, to generate a PDF by LilyPond engraving, run

    $ rake pdf

This will generate a .pdf file for each score file. In addition, this would cause a chain of intermediate files to be created as well, as follows:

    fname.score -> fname.yml -> fname.ly -> fname.pdf

The supported final target formats are listed in the table below.

| Target format | Rake command |
|---------------|--------------|
| MIDI | midi |
| LilyPond PDF | pdf |
| LilyPond PNG | png |
| LilyPond PostScript | ps |
| SuperCollider AIFF | aiff |
| SuperCollider WAV | wav |
| SuperCollider FLAC | flac |

In addition, there are also commands for all the intermediate formats
| Target format | Rake command |
|---------------|--------------|
| YAML | yaml |
| LilyPond (text) | ly |
| Raw OSC (binary) | osc |

## Contributing

1. Fork it ( https://github.com/[my-github-username]/musicality/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
