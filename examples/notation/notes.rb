require 'musicality'
include Musicality
include Pitches

#
# convenience methods for common durations
#
single = Note.quarter(Ab4)
rest = Note.quarter
chord = Note.whole([C3,E3,G3])

#
# specific duration + articulation
#
note = Note.new(Rational(7,8), Bb3, articulation: Articulations::STACCATO)
puts note.to_s  # => "7/8Bb3."

#
# magic!
#
puts note.transpose(2).to_s  # => "7/8C4."

#
# create notes from a compact syntax
#
notes = "/4C3 /4D3 /2E3,G3,B3".to_notes
puts notes.join(" ") # => "/4C3 /4D3 /2E3,G3,B3"