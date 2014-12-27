module Musicality

class Probabilities
  def self.uniform n
    probs = [1/n.to_f]*n
    sum = probs.inject(0,:+)
    if sum != 1
      probs[0] += (1 - sum)
    end
    return probs
  end
  
  def self.random n
    cumulative_probs = Array.new(n-1){ rand }.sort + [1]
    x0 = 0
    cumulative_probs.map {|x| y = x - x0; x0 = x; y }
  end
end

end