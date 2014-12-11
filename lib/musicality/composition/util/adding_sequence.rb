module Musicality
  
class AddingSequence
  include BiInfiniteSequence
  
  attr_reader :start_value
  def initialize pattern, start_val = 0
    raise EmptyError if pattern.empty?
    @pattern = pattern
    @n = pattern.size
    @start_value = start_val
  end
  
  def pattern_size; @pattern.size; end
  
  def next_value cur_val, cur_idx
    cur_val + @pattern[cur_idx % @n]
  end  
  def prev_value cur_val, cur_idx
    cur_val - @pattern[(cur_idx-1) % @n]
  end
end

end