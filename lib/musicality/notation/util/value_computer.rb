module Musicality

# Given a start value, and value changes, compute the value at any offset.
class ValueComputer
  attr_reader :piecewise_function

  def initialize start_value, value_changes = {}
    @piecewise_function = PiecewiseFunction.new
    set_default_value start_value
    
    if value_changes.any?
      value_changes.sort.each do |offset,change|
        
        case change
        when Change::Immediate
          add_immediate_change change, offset
        when Change::Gradual
          case change.transition
          when Change::Gradual::LINEAR
            add_linear_change change, offset
          when Change::Gradual::SIGMOID
            add_sigmoid_change change, offset
          end
        end
      end
    end
  end

  # Compute the value at the given offset.
  # @param [Numeric] offset The given offset to compute value at.
  def value_at offset
    @piecewise_function.eval offset
  end
  
  def sample xmin, xmax, srate
    sample_period = Rational(1,srate)
    ((xmin.to_r)..(xmax.to_r)).step(sample_period).map do |x|
      value_at(x)
    end
  end
  
  # finds the minimum domain value
  def domain_min
    -Float::INFINITY
  end

  # finds the maximum domain value
  def domain_max
    Float::INFINITY
  end

  # finds the minimum domain value
  def self.domain_min
    -Float::INFINITY
  end

  # finds the maximum domain value
  def self.domain_max
    Float::INFINITY
  end

  private

  def set_default_value value
    func = lambda {|x| value }
    @piecewise_function.add_piece( domain_min..domain_max, func )
  end
  
  # Add a function piece to the piecewise function, which will to compute value
  # for a matching note offset. Transition duration will be ignored since the
  # change is immediate.
  #
  # @param [ValueChange] value_change An event with information about the new value.
  # @param [Numeric] offset
  def add_immediate_change value_change, offset
    func = nil
    value = value_change.end_value
    domain = offset..domain_max
    func = lambda {|x| value }
    
    @piecewise_function.add_piece domain, func
  end
    
  # Add a function piece to the piecewise function, which will to compute value
  # for a matching note offset. If the dynamic event duration is non-zero, a 
  # linear transition function is created.
  #
  # @param [ValueChange] value_change An event with information about the new value.
  # @param [Numeric] offset
  def add_linear_change value_change, offset
    
    func = nil
    value = value_change.end_value
    duration = value_change.duration
    domain = offset..domain_max
    
    if duration == 0
      add_immediate_change(value_change, offset)
    else
      b = @piecewise_function.eval domain.first
      m = (value.to_f - b.to_f) / duration.to_f
      
      func = lambda do |x|
        raise RangeError, "#{x} is not in the domain" if !domain.include?(x)
        
        if x < (domain.first + duration)
          (m * (x - domain.first)) + b
        else
          value
        end
      end
      @piecewise_function.add_piece domain, func
    end
  end

  # Add a function piece to the piecewise function, which will to compute value
  # for a matching note offset. If the dynamic event duration is non-zero, a 
  # linear transition function is created.
  #
  # @param [ValueChange] value_change An event with information about the new value.
  # @param [Numeric] offset
  def add_sigmoid_change value_change, offset
    
    func = nil
    start_value = @piecewise_function.eval offset
    end_value = value_change.end_value
    value_diff = end_value - start_value
    duration = value_change.duration
    domain = offset.to_f..domain_max
    abruptness = 0.7 # value_change.transition.abruptness.to_f

    if duration == 0
      add_immediate_change(value_change,offset)
    else
      sigm_domain = -5..5
      sigm_range = sigm(sigm_domain.first)..sigm(sigm_domain.last)
      sigm_span = sigm_range.last - sigm_range.first

      func = lambda do |x|
        raise RangeError, "#{x} is not in the domain" if !domain.include?(x)
          if x < (domain.first + duration)
            start_domain = domain.first...(domain.first + duration)
            x2 = transform_domains(start_domain, sigm_domain, x)
            y = sigm(x2) - sigm_range.first
            z = (y / sigm_span)
            start_value + (z * value_diff)
          else
            end_value
          end
      end
      
      @piecewise_function.add_piece domain, func
    end
  end

  # x should be in the start domain 
  def transform_domains start_domain, end_domain, x
    perc = (x - start_domain.first) / (start_domain.last - start_domain.first).to_f
    x2 = perc * (end_domain.last - end_domain.first) + end_domain.first
  end

  # Sigmoid function using the logisitic function, which ranges from 0 to 1,
  # with x from -5 to 5 being a good domain
  def sigm x
    1.0 / (1 + Math::exp(-x))
  end
end

end