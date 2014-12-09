module Musicality
  
class RepeatingSequence
  include InfiniteSequence
  
  attr_reader :start_value
  def initialize pattern
    raise EmptyError if pattern.empty?
    @pattern = pattern
    @n = pattern.size
    @start_value = pattern.first
  end
    
  class Infinite < RepeatingSequence; end
  
  class BiInfinite < RepeatingSequence
    include BiInfiniteSequence
    
    private
    def prev_value cur_val, cur_idx
      @pattern[(cur_idx - 1) % @n]        
    end
  end
  
  private    
  def next_value cur_val, cur_idx
    @pattern[(cur_idx + 1) % @n]      
  end
end

end