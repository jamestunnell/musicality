module Musicality

class Change
  attr_reader :value, :duration
  
  def initialize value, duration
    @value = value
    @duration = duration
  end
  
  def ==(other)
    self.class == other.class &&
    self.value == other.value &&
    self.duration == other.duration
  end

  class Immediate < Change
    def initialize value
      super(value,0)
    end
    
    def clone
      Immediate.new(@value)
    end
    
    def resize newdur
      self.clone
    end
  end
  
  class Gradual < Change
    def initialize value, transition_dur
      if transition_dur <= 0
        raise NonPositiveError, "transition duration #{transition_dur} must be positive"
      end
      super(value, transition_dur)
    end
    
    def clone
      Gradual.new(@value,@duration)
    end
    
    def resize newdur
      Gradual.new(@value,newdur)
    end
  end
  
  class Partial < Change
    attr_reader :elapsed, :impending, :remaining
    
    def initialize value, elapsed, impending, remaining
      if elapsed < 0
        raise NegativeError, "elapsed (#{elapsed}) is < 0"
      end
      
      if impending <= 0
        raise NonPositiveError, "impending (#{impending}) is <= 0"
      end
      
      if remaining < 0
        raise NegativeError, "remaining #{remaining} is < 0"
      end
      
      @total_duration = elapsed + impending + remaining
      @elapsed = elapsed
      @impending = impending
      @remaining = remaining
      super(value,impending)
    end
    
    def ==(other)
      super() &&
      @elapsed == other.elapsed &&
      @impending == other.impending &&
      @remaining == other.remaining
    end
  end
end

end