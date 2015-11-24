module Musicality

class MidiUtil
  QUARTER = Rational(1,4)    
  # Number of pulses equivalent to the given duration
  def self.delta duration, ppqn
    pulses = (duration / QUARTER) * ppqn
    return pulses.round
  end
  
  p0 = Pitch.new(octave:-1,semitone:0)
  PITCH_TO_NOTENUM = {}
  NOTENUM_TO_PITCH = {}
  
  (0..127).each do |note_num|
    pitch = p0.transpose(note_num)
    PITCH_TO_NOTENUM[pitch] = note_num
    NOTENUM_TO_PITCH[note_num] = pitch
  end
  
  def self.pitch_to_notenum pitch
    PITCH_TO_NOTENUM.fetch(pitch.round)
  end
  
  def self.notenum_to_pitch notenum
    NOTENUM_TO_PITCH.fetch(notenum)
  end
  
  def self.dynamic_to_volume dynamic
    (dynamic * 127).round
  end
  
  def self.note_velocity(attack)
    case attack
    when Attack::NORMAL, Attack::NONE then 70
    when Attack::TENUTO then 90
    when Attack::ACCENT then 112
    else
      raise ArgumentError
    end
  end
end

end