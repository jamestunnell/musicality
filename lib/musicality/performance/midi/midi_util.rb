module Musicality

class MidiUtil
  QUARTER = Rational(1,4)    
  # Number of pulses equivalent to the given duration
  def self.delta duration, ppqn
    pulses = (duration / QUARTER) * ppqn
    return pulses.round
  end
  
  p0 = Pitch.new(octave:-1,semitone:0)
  MIDI_NOTENUMS = Hash[
    (0..127).map do |note_num|
      [ p0.transpose(note_num), note_num ]
    end
  ]
  
  def self.pitch_to_notenum pitch
    MIDI_NOTENUMS.fetch(pitch.round)
  end
  
  def self.dynamic_to_volume dynamic
    (dynamic * 127).round
  end
  
  def self.note_velocity(accented)
    accented ? 112 : 70
  end
end

end