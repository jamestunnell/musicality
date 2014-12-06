module Musicality

class IntervalArray < Array
  class Relative < IntervalArray
    def to_pitches base_pitch
      prev = base_pitch
      map {|n| prev = prev.transpose(n) }
    end
    
    def to_pcs base_pc
      prev_pc = base_pc
      map {|int| prev_pc += int }.to_pcs
    end
    
    def to_absolute_intervals
      sum = 0
      map {|n| sum += n }
    end
  end

  class Absolute < IntervalArray
    def to_pitches base_pitch
      map {|n| base_pitch.transpose(n) }
    end
    
    def to_pcs base_pc
      map {|int| base_pc + int }.to_pcs
    end
        
    def to_relative_intervals
      prev = 0
      map {|n| rel = n - prev; prev = n; rel }
    end
  end
end

end