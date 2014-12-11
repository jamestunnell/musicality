module Enumerable
  def map_with_index
    return enum_for(:map_with_index) unless block_given?
    ary = entries
    Array.new(ary.size) do |i|
      yield ary[i], i
    end
  end
end

module Musicality

module BiInfiniteSequence
  def at offset
    if offset.is_a? Enumerable
      return enum_for(:at,offset) unless block_given?
    else
      return at_one(offset)
    end
    
    offset_index_pairs = offset.map_with_index {|x,i| [x,i] }.sort
    results = Array.new(offset.size)
    
    past = offset_index_pairs.select {|p| p[0] < 0 }
    present = offset_index_pairs.select {|p| p[0] == 0 }
    future = offset_index_pairs.select {|p| p[0] > 0 }
    
    start_val = start_value
    
    if past.any?
      value = start_val
      j = past.size - 1
      tgt_offset = past[j][0]
      0.downto(past.first[0]+1) do |i|
        value = prev_value(value,i)
        while (i-1) == tgt_offset
          results[past[j][1]] = value
          j -= 1
          tgt_offset = j >= 0 ? past[j][0] : nil
        end
      end
    end
    
    if present.any?
      present.each do |off,index|
        results[index] = start_val
      end
    end
    
    if future.any?
      value = start_val
      j = 0
      tgt_offset = future[j][0]
      0.upto(future.last[0]-1) do |i|
        value = next_value(value,i)
        while (i+1) == tgt_offset
          results[future[j][1]] = value
          j += 1
          tgt_offset = j < future.size ? future[j][0] : nil
        end
      end
    end
    
    results.each {|x| yield x }
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
  
  private
  
  def at_one offset
    value = start_value
    if offset >= 0
      0.upto(offset-1) do |i|
        value = next_value(value,i)
      end
    else
      0.downto(offset+1) do |i|
        value = prev_value(value,i)
      end
    end
    return value
  end
end

end