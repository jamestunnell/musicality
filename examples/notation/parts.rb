require 'musicality'
include Musicality
include Pitches
include Dynamics


#
# Building up a part piece-by-piece
#

# an empty part with no notes and default dynamic (loudness)
p = Part.new(MP)

# add some notes
p.notes += "/4C3 /4D3 /2E3,G3,B3".to_notes * 2

# add dynamic changes
p.dynamic_changes[0.5] = Change::Gradual.linear(FF, 0.5)
p.dynamic_changes[1] = Change::Immediate.new(MP)

# Add custom settings for LilyPond engraving
p.settings.push LilypondSettings::CLARINET

# Add custom settings for MIDI conversion
p.settings.push MidiSettings::CLARINET


#
# Using block initialization to do the same
#

p = Part.new(MP) do |p|
  p.notes += "/4C3 /4D3 /2E3,G3,B3".to_notes * 2
  p.dynamic_changes[0.5] = Change::Gradual.linear(FF, 0.5)
  p.dynamic_changes[1] = Change::Immediate.new(MP)
  p.settings.push LilypondSettings::CLARINET
  p.settings.push MidiSettings::CLARINET
end


#
# Passing all the pieces as keyword parameters
#
p = Part.new(MP,
  notes: "/4C3 /4D3 /2E3,G3,B3".to_notes * 2,
  dynamic_changes: {
    0.5 => Change::Gradual.linear(FF, 0.5),
    1.0 => Change::Immediate.new(MP)
  },
  settings: [ LilypondSettings::CLARINET, MidiSettings::CLARINET ]
)