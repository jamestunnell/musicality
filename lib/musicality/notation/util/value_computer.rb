module Musicality

# Given a start value, and value changes, compute the value at any offset.
class ValueComputer
  DOMAIN_MIN, DOMAIN_MAX = -Float::INFINITY, Float::INFINITY
  
  attr_reader :piecewise_function
  def initialize start_value, value_changes = {}
    @piecewise_function = Function::Piecewise.new
    set_default_value(start_value)
    if value_changes.any?
      value_changes.sort.each do |offset,change|
        add_change(offset, change)
      end
    end
  end

  def value_at offset
    @piecewise_function.eval offset
  end
  
  def sample xmin, xmax, srate
    sample_period = Rational(1,srate)
    ((xmin.to_r)..(xmax.to_r)).step(sample_period).map do |x|
      value_at(x)
    end
  end
  
  private

  def add_change offset, change
    start_value = @piecewise_function.eval(offset)
    func = change.to_function(offset, start_value)
    @piecewise_function.add_piece(offset..DOMAIN_MAX, func)
  end
  
  def set_default_value value
    func = Function::Constant.new(value)
    @piecewise_function.add_piece(DOMAIN_MIN..DOMAIN_MAX, func)
  end
end

end