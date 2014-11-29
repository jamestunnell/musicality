module Musicality

class Function
  # x  in start domain, transformed to x in end domain
  def self.transform_domains start_domain, end_domain, x
    perc = (x - start_domain.first) / (start_domain.last - start_domain.first).to_f
    return perc * (end_domain.last - end_domain.first) + end_domain.first
  end
  
  class Constant < Function
    def initialize value
      @value = value
    end
    
    def eval(x)
      @value
    end
  end
  
  class Linear < Function
    def initialize p1,p2
      @slope = (p2[1] - p1[1])/(p2[0] - p1[0]).to_f
      @intercept = p1[1] - @slope * p1[0]
    end
    
    def eval(x)
      x * @slope + @intercept
    end
  end
  
  class Sigmoid < Function
    def self.sigm x
      Rational(1, 1 + Math::exp(-x))
    end
    
    SIGM_DOMAIN = -5..5
    SIGM_RANGE = Sigmoid.sigm(SIGM_DOMAIN.first)..Sigmoid.sigm(SIGM_DOMAIN.last)
    SIGM_SPAN = SIGM_RANGE.last - SIGM_RANGE.first
    
    def initialize p0, p1
      @y0, @y1 = p0[1], p1[1]
      @dy = @y1 - @y0
      @transition_domain = p0[0]..p1[0]
    end
    
    def eval(x)
      if x < @transition_domain.first
        @y0  
      elsif x >= @transition_domain.last
        @y1
      else
        x2 = Function.transform_domains(@transition_domain, SIGM_DOMAIN, x)
        y2 = (Sigmoid.sigm(x2) - SIGM_RANGE.first) / SIGM_SPAN
        @y0 + y2 * @dy
      end
    end
  end
end

end
