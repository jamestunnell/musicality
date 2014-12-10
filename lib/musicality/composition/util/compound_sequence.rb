module Musicality

class CompoundSequence
  def initialize combine_method, sequences
    @seqs = sequences
    @comb_meth = combine_method
  end
  
  def at offset
    vals = @seqs.map {|s| s.at(offset) }
    combine vals
  end
  
  def take n
    enums = @seqs.map {|s| s.take(n) }
    Array.new(n) do
      vals = enums.map {|e| e.next }
      combine vals
    end
  end
  
  def over range
    enums = @seqs.map {|s| s.over(range) }
    Array.new(range.size) do
      vals = enums.map {|e| e.next }
      combine vals
    end
  end
  
  def take_back n
    enums = @seqs.map {|s| s.take_back(n) }
    Array.new(n) do
      vals = enums.map {|e| e.next }
      combine vals
    end
  end
  
  private
  def combine vals
    vals[1..-1].inject(vals.first,@comb_meth)
  end
end

end
