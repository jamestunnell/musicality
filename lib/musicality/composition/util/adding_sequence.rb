module Musicality
  
class AddingSequence
  include InfiniteSequence
  
  attr_reader :start_value
  def initialize pattern, start_val = 0
    raise EmptyError if pattern.empty?
    @pattern = pattern
    @n = pattern.size
    @start_value = start_val
  end
  
  class Infinite < AddingSequence; end
  
  class BiInfinite < AddingSequence
    include BiInfiniteSequence
    
    private
    def prev_value cur_val, cur_idx
      cur_val - @pattern[(cur_idx-1) % @n]
    end
  end

  private  
  def next_value cur_val, cur_idx
    cur_val + @pattern[cur_idx % @n]
  end  
end

end