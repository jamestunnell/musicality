module Musicality
  
class Scale
  attr_reader :pitch_class
  def initialize pitch_class, intervals
    @pitch_class = pitch_class
    @intervals = intervals
  end
  
  def intervals; @intervals.entries; end

  def size
    @intervals.size
  end
  
  def transpose diff
    new_pc = (@pitch_class + diff).to_pc
    Scale.new(new_pc,@intervals)
  end
  
  def rotate n
    diff = AddingSequence.new(@intervals).at(n)
    new_pc = (@pitch_class + diff).to_pc
    new_intervals = @intervals.rotate(n)
    Scale.new(new_pc,new_intervals)
  end
  
  def at_octave octave
    start_pitch = Pitch.new(octave: octave, semitone: @pitch_class)
    AddingSequence.new(@intervals, start_pitch)
  end
end

end