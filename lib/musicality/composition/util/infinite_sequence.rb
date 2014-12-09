module Musicality

module InfiniteSequence
  def at offset
    raise NegativeError if offset < 0
    
    value = start_value
    0.upto(offset-1) do |i|
      value = next_value(value,i)
    end
    return value
  end
  
  def take n
    raise NegativeError if n < 0
    return enum_for(:take,n) unless block_given?
    return if n == 0
    
    value = start_value
    0.upto(n - 1) do |i|
      yield value
      value = next_value(value,i)
    end
  end
  
  def over range
    min, max = range.minmax
    raise EmptyError, "given range (#{range}) is empty" if min.nil?
    raise NegativeError, "range min is < 0" if min < 0
    raise NegativeError, "range max is < 0" if max < 0
    return enum_for(:over,range) unless block_given?
    
    value = at(min)
    range.each do |i|
      yield value
      value = next_value(value,i)
    end
  end
end

end