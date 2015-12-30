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

  attr_reader :domain
  def initialize domain = (DOMAIN_MIN...DOMAIN_MAX), memoize: true, &at_block
    raise ArgumentError unless domain.last > domain.first
    @domain = domain
    raise ArgumentError unless block_given?
    raise ArgumentError unless at_block.arity == 1
    @at_block = at_block

    @memoize = memoize
    @memoized = {}
  end

  def at(x)
    raise DomainError unless @domain.include?(x)
    if @memoize
      if @memoized.has_key? x
        @memoized[x]
      else
        @memoized[x] = @at_block.call(x)
      end
    else
      @at_block.call(x)
    end
  end

  def ==(other)
    @domain == other.domain
  end

  class Constant < Function
    attr_reader :value
    
    def initialize value
      @value = value
      super() {|x| @value }
    end
    
    def ==(other)
      super(other) && @value == other.value
    end
  end
  
  class Linear < Function
    attr_reader :slope, :intercept
    
    def initialize p1,p2
      @slope = (p2[1] - p1[1])/(p2[0] - p1[0]).to_f
      @intercept = p1[1] - @slope * p1[0]

      super() {|x| x * @slope + @intercept }
    end
    
    def ==(other)
      super(other) && @slope == other.slope && @intercept == other.intercept
    end
  end
  
  class Sigmoid < Function
    def self.sigm x
      1.0 / (1 + Math::exp(-x))
    end
    
    #def self.inv_sigm y
    #  -Math::log((1-y)/y.to_f)
    #end
    
    SIGM_DOMAIN = -5..5
    SIGM_RANGE = Sigmoid.sigm(SIGM_DOMAIN.first)..Sigmoid.sigm(SIGM_DOMAIN.last)
    SIGM_SPAN = SIGM_RANGE.last - SIGM_RANGE.first
    
    attr_reader :y0, :dy
    def initialize p0, p1
      @y0, y1 = p0[1], p1[1]
      @dy = y1 - @y0
      @external_domain = p0[0]..p1[0]

      super() do |x|
        x_ = Function.transform_domains(@external_domain, SIGM_DOMAIN, x)
        y_ = (Sigmoid.sigm(x_) - SIGM_RANGE.first) / SIGM_SPAN
        @y0 + y_ * @dy
      end
    end
    
    #def from(y)
    #  y2 = (y - @y0) / @dy
    #  x2 = Sigmoid.inv_sigm(y2 * SIGM_SPAN + SIGM_RANGE.first)
    #  x = Function.transform_domains(SIGM_DOMAIN, @external_domain, x2)
    #  return x
    #end
    
    # Given a domain, an xy-point in that domain, and the y-value at
    # the end of the domain, find the y-value at the start of the domain,
    # assuming the the function is sigmoid.
    def self.find_y0 domain, pt, y1
      x,y = pt
      x_ = Function.transform_domains(domain, SIGM_DOMAIN, x)
      y_ = (sigm(x_) - SIGM_RANGE.first) / SIGM_SPAN
      return Function::Linear.new([y_,y],[1,y1]).at(0)
    end
      
    def ==(other)
      super(other) && @y0 == other.y0 && @dy == other.dy
    end
  end  
end

end
