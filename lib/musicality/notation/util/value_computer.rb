module Musicality

# Given a start value, and value changes, compute the value at any offset.
class ValueComputer < Function::Piecewise
  attr_reader :piecewise_function
  def initialize start_value, value_changes = {}
    super()
    set_default_value(start_value)
    if value_changes.any?
      value_changes.sort.each do |offset,change|
        add_change(offset, change)
      end
    end
  end
    
  private

  def add_change offset, change
    start_value = at(offset)
    trans = change.to_transition(offset, start_value)
    add_piece(offset..Function::DOMAIN_MAX, trans)
  end
  
  def set_default_value value
    func = Function::Constant.new(value)
    add_piece(Function::DOMAIN_MIN..Function::DOMAIN_MAX, func)
  end
end

end