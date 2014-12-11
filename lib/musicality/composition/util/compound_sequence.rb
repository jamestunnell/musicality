module Musicality

class CompoundSequence
  def initialize combine_method, sequences
    @seqs = sequences
    @comb_meth = combine_method
  end
  
  def at offset
    if offset.is_a? Enumerable
      return enum_for(:at,offset) unless block_given?
      enums = @seqs.map {|s| s.at(offset) }
      offset.size.times { yield combine(enums.map {|e| e.next }) }
    else
      vals = @seqs.map {|s| s.at(offset) }
      return combine(vals)
    end
  end
  
  def take n
    return enum_for(:take,n) unless block_given?
    enums = @seqs.map {|s| s.take(n) }
    n.times { yield combine(enums.map {|e| e.next }) }
  end
  
  def over range
    return enum_for(:over,range) unless block_given?
    enums = @seqs.map {|s| s.over(range) }
    range.size.times { yield combine(enums.map {|e| e.next }) }
  end
  
  def take_back n
    return enum_for(:take_back,n) unless block_given?
    enums = @seqs.map {|s| s.take_back(n) }
    n.times { yield combine(enums.map {|e| e.next }) }
  end
  
  private
  def combine vals
    vals[1..-1].inject(vals.first,@comb_meth)
  end
end

end
