require 'set'

module Musicality

class IntervalArray < Array
  class Absolute < IntervalArray
    def to_pitches base_pitch
      map {|int| base_pitch.transpose(int) }
    end
    
    def to_pcs base_pc
      map {|int| base_pc + int }.to_pcs
    end
  end
  
  class Relative < IntervalArray
    def to_pitches base_pitch
      prev_pitch = base_pitch
      map {|int| prev_pitch = prev_pitch.transpose(int) }
    end
    
    def to_pcs base_pc
      prev_pc = base_pc
      map {|int| prev_pc += int }.to_pcs
    end
  end
end

end