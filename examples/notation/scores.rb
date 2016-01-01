require 'musicality'
include Musicality
include Pitches
include Dynamics
include Keys
include Meters

#
# Basics of creating a score from scratch
#

# minimum score, with no parts
s = Score::Tempo.new(FOUR_FOUR, 120)

# add a part
s.parts["piano"] = Part.new(MP) do |p|
  p.notes = q(C4,C4,G4,G4,A4,A4) + h(G4) + 
            q(F4,F4,E4,E4,D4,D4) + h(C4)
end

# add a key and tempo change
s.key_changes[s.measures_long] = Change::Immediate.new(D_MAJOR)
s.tempo_changes[s.measures_long] = Change::Immediate.new(140)
s.parts["piano"].notes += transpose(s.parts["piano"].notes, 2)


#
# Score conversion
#

# Convert tempo-based score to time-based
s.to_timed(200) # requires tempo sampling rate

# Engrave the score using LilyPond
puts s.to_lilypond

# Convert the score to a MIDI file
s.to_midi_seq(200)
