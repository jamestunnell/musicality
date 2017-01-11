module Musicality

class DrumPattern
  attr_reader :part_notes, :duration

  DUMMY_PITCH = Pitches::C4

  def initialize duration, part_name_portions
    @duration = duration
    @part_notes = Hash[ part_name_portions.map do |part_name, portions|
      [ part_name, portions.to_rhythm_class.to_rhythm(duration).to_notes(DUMMY_PITCH) ]
    end ]
  end
end

end
