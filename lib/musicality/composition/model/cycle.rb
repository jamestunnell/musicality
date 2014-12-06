module Musicality

class Cycle
  def initialize pattern
    raise EmptyError, "pattern is empty" if pattern.empty?
    @pattern = pattern
    @n = @pattern.size
  end
  
  def at offset
    @pattern[offset % @n]
  end
  
  def size
    @pattern.size
  end
  
  def pattern
    return @pattern.each unless block_given?
    @pattern.each do |x|
      yield x
    end
  end
  
  def over range
    return enum_for(:over,range) unless block_given?
    
    first, last = range.first, range.last
    if first <= last
      range.each do |i|
        yield @pattern[i % @n]
      end
    else
      if range.exclude_end?
        last += 1
      end
      first.downto(last) do |i|
        yield @pattern[i % @n]
      end
    end
  end
end

end

class Array
  def to_cycle
    Cycle.new(self)
  end
end