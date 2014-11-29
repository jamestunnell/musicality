module Musicality

class Function
  DOMAIN_MIN, DOMAIN_MAX = -Float::INFINITY, Float::INFINITY
  
  def sample xrange, srate
    xrange.step(Rational(1,srate)).map { |x| at(x) }
  end

  # x  in start domain, transformed to x in end domain
  def self.transform_domains start_domain, end_domain, x
    perc = (x - start_domain.first) / (start_domain.last - start_domain.first).to_f
    return perc * (end_domain.last - end_domain.first) + end_domain.first
  end
  
  class Constant < Function
    attr_reader :value
    
    def initialize value
      @value = value
    end
    
    def at(x)
      @value
    end
    
    def ==(other)
      @value == other.value
    end
  end
  
  class Linear < Function
    attr_reader :slope, :intercept
    
    def initialize p1,p2
      @slope = (p2[1] - p1[1])/(p2[0] - p1[0]).to_f
      @intercept = p1[1] - @slope * p1[0]
    end
    
    def at(x)
      x * @slope + @intercept
    end
    
    def ==(other)
      @slope == other.slope && @intercept == other.intercept
    end
  end
  
  class Sigmoid < Function
    def self.sigm x
      1.0 / (1 + Math::exp(-x))
    end
    
    def self.inv_sigm y
      -Math::log((1-y)/y.to_f)
    end
    
    SIGM_DOMAIN = -5..5
    SIGM_RANGE = Sigmoid.sigm(SIGM_DOMAIN.first)..Sigmoid.sigm(SIGM_DOMAIN.last)
    SIGM_SPAN = SIGM_RANGE.last - SIGM_RANGE.first
    
    attr_reader :y0, :dy, :transition_domain
    def initialize p0, p1
      @y0, y1 = p0[1], p1[1]
      @dy = y1 - @y0
      @transition_domain = p0[0]..p1[0]
    end
    
    def at(x)
      x2 = Function.transform_domains(@transition_domain, SIGM_DOMAIN, x)
      y2 = (Sigmoid.sigm(x2) - SIGM_RANGE.first) / SIGM_SPAN
      @y0 + y2 * @dy
    end
    
    def ==(other)
      @y0 == other.y0 && @dy == other.dy &&
      @transition_domain == other.transition_domain
    end
  end
  
  class InverseSigmoid < Function
    INV_SIGM_DOMAIN = 0..1
    INV_SIGM_RANGE = -5..5
    INV_SIGM_SPAN = 10
    
    def self.inv_sigm y
      -Math::log((1-y)/y.to_f)
    end
    
    def initialize p0, p1
    end
    
    def at(y)
      
    end
  end
end

end
