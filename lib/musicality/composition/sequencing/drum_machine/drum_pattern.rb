module Musicality

class DrumPattern
  attr_reader :part_notes

  DEFAULT_PITCH = Pitches::C4

  def initialize part_name_portions, total_duration, pitch: DEFAULT_PITCH
    @part_notes = Hash[ part_name_portions.map do |part_name, portions|
      [ part_name, portions.to_rhythm_class.to_rhythm(total_duration).to_notes(pitch) ]
    end ]
  end
end

end
