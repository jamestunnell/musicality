module Musicality

class RandomSampler
  attr_reader :values, :probabilities
  def initialize vals, probs
    @values, @probabilities = vals, probs
    total_prob = probs.inject(0,:+)
    raise ArgumentError, "Total probability is not 1" if total_prob != 1
    
    offsets = AddingSequence.new(probs).over(1...probs.size).to_a
    changes = vals[1..-1].map{|val| Change::Immediate.new(val) }
    
    value_changes = Hash[ [offsets, changes].transpose ]
    @val_comp = ValueComputer.new(vals.first, value_changes)
  end
  
  def sample
    @val_comp.at(rand)
  end
end

end
