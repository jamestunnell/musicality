module Musicality

class RandomRhythmGenerator
  attr_reader :durations, :probabilities
  
  def initialize palette_with_probs
    @durations, @probabilities = palette_with_probs.entries.transpose
    @dur_sampler = RandomSampler.new(@durations,@probabilities)
  end
  
  def random_dur
    @dur_sampler.sample
  end
  
  def random_rhythm target_dur, end_retries = 5
    rhythm = []
    total_dur = 0
    retries = 0
    
    while(total_dur < target_dur && retries < end_retries)
      dur = random_dur
      
      if (dur + total_dur) <= target_dur
        total_dur += dur
        rhythm.push(dur)
      else
        retries += 1
      end
    end
    
    if total_dur < target_dur
      rhythm.push(target_dur - total_dur)
    end
    
    return rhythm
  end
end

end