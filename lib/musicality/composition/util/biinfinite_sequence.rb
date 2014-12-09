module Musicality

module BiInfiniteSequence
  include InfiniteSequence
  
  alias :at_pos :at
  def at offset
    return at_pos(offset) if offset >= 0
    
    value = start_value
    0.downto(offset+1) do |i|
      value = prev_value(value,i)
    end
    return value
  end
  
  def take_back n
    raise NegativeError if n < 0
    return enum_for(:take_back,n) unless block_given?
    return if n == 0
    
    value = start_value
    0.downto(1 - n) do |i|
      yield value = prev_value(value,i)
    end
  end
  
  def over range
    min, max = range.minmax
    raise EmptyError, "given range (#{range}) is empty" if min.nil?
    return enum_for(:over,range) unless block_given?

    if min >= 0 && max >= 0
      value = at(min)
      range.each do |i|
        yield value
        value = next_value(value,i)
      end
    elsif max < 0
      value = at(max+1)
      values = range.entries.reverse.map do |i|
        value = prev_value(value,i+1)
      end
      values.reverse_each {|x| yield x }
    else
      take_back(-min).reverse_each {|x| yield x }
      take(max + 1){ |x| yield x }
    end
  end
end

end