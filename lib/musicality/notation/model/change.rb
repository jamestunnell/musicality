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
  end
  
  class Gradual < Change
    attr_reader :elapsed, :impending, :remaining, :total_duration
    
    def initialize value, impending, elapsed=0, remaining=0
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
      super(other) &&
      @elapsed == other.elapsed &&
      @remaining == other.remaining
    end
    
    def clone
      Gradual.new(@value, @impending, @elapsed, @remaining)
    end
  end
end

end