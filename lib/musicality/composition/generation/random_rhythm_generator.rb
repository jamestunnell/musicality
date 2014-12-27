module Musicality

class RandomRhythmGenerator
  def initialize palette_with_probs
    total_prob = palette_with_probs.values.inject(0,:+)
    raise ArgumentError, "Total probability is not 1" if total_prob != 1
    
    durs, probs = palette_with_probs.entries.transpose
    
    offsets = AddingSequence.new(probs).over(1...probs.size).to_a
    changes = durs[1..-1].map{|dur| Change::Immediate.new(dur) }
    
    value_changes = Hash[ [offsets, changes].transpose ]
    @dur_comp = ValueComputer.new(durs.first, value_changes)
  end
  
  def random_dur
    @dur_comp.at(rand)
  end
  
  def random_rhythm target_dur
    rhythm = []
    dur = total_dur = random_dur
    
    while(total_dur <= target_dur)
      rhythm.push(dur)
      dur = random_dur
      total_dur += dur
    end
    
    if total_dur < target_dur
      rhythm.push(target_dur - total_dur)
    end
    
    return rhythm
  end
  
  
  class Uniform < RandomRhythmGenerator
    def initialize total_dur, palette
      n = palette.size
      probabilities = [1/n.to_r]*n
      super()
    end
  end
end

end