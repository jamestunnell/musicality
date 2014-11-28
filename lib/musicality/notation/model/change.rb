module Musicality

class Change
  attr_reader :end_value
  
  def initialize end_value
    @end_value = end_value
  end
  
  def ==(other)
    self.class == other.class &&
    self.end_value == other.end_value
  end
  
  class Immediate < Change
    def initialize value
      super(value)
    end
    
    def clone
      Immediate.new(@end_value)
    end
    
    def duration; 0; end
  end
  
  class Gradual < Change
    attr_reader :duration, :transition
    LINEAR = :linear
    SIGMOID = :sigmoid
    TRANSITIONS = [LINEAR,SIGMOID]
    
    def self.linear end_value, duration
      Gradual.new(end_value, duration, LINEAR)
    end

    def self.sigmoid end_value, duration
      Gradual.new(end_value, duration, SIGMOID)
    end
    
    def initialize end_value, duration, transition
      if duration <= 0
        raise NonPositiveError, "duration (#{duration}) is <= 0"
      end
      
      unless TRANSITIONS.include?(transition)
        raise ArgumentError, "transition (#{transition}) is not supported"
      end
      
      @duration = duration
      @transition = transition
      super(end_value)
    end
    
    def ==(other)
      super(other) && @duration == other.duration &&
      @transition == other.transition
    end
    
    def clone
      Gradual.new(@end_value, @duration, @transition)
    end
    
    class Trimmed < Gradual
      attr_reader :preceding, :remaining
      
      def self.linear end_value, duration, preceding: 0, remaining: 0
        Trimmed.new(end_value, duration, LINEAR, preceding: preceding, remaining: remaining)
      end
      
      def self.sigmoid end_value, duration, preceding: 0, remaining: 0
        Trimmed.new(end_value, duration, SIGMOID, preceding: preceding, remaining: remaining)
      end
      
      def initialize end_value, duration, transition, preceding: 0, remaining: 0
        if preceding < 0
          raise NegativeError, "preceding (#{preceding}) is < 0"
        end
        
        if remaining <= 0
          raise NonPositiveError, "remaining (#{remaining}) is <= 0"
        end
        
        @preceding, @remaining = preceding, remaining
        super(end_value, duration, transition)
      end
      
      def ==(other)
        super(other) && @preceding == other.preceding && @remaining == other.remaining
      end
    
      def clone
        Trimmed.new(@end_value, @duration, @transition,
                    preceding: @preceding, remaining: @remaining)
      end
    end
    
    def trim_left(amount)
      Trimmed.new(@end_value, @duration, @transition,
                  preceding: amount, remaining: (@duration - amount))
    end
    
    def trim_right(amount)
      Trimmed.new(@end_value, @duration, @transition,
                  preceding: 0, remaining: (@duration - amount))
    end
    
    def trim(ltrim, rtrim)
      Trimmed.new(@end_value, @duration, @transition, 
                  preceding: ltrim, remaining: (@duration - ltrim - rtrim))
    end
    
    def to_trimmed(preceding, remaining)
      Trimmed.new(@end_value, @duration, @transition,
                  preceding: preceding, remaining: remaining)
    end
  end
end

end