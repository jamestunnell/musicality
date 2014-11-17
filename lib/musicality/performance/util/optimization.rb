module Musicality

module Optimization
  def self.linking unlinked, untargeted
    n = [unlinked.size, untargeted.size].min
    
    bestsol = nil
    bestscore = Float::INFINITY
    unlinked.combination(n).each do |comb|
      untargeted.permutation(n).each do |perm|
        score = 0
        n.times do |i|
          score += perm[i].diff(comb[i]).abs
        end
        
        if score < bestscore
          bestsol = [ comb, perm ]
          bestscore = score
        end
      end
    end
    
    solution = {}
    n.times do |i|
      solution[ bestsol[0][i] ] = bestsol[1][i]
    end
    return solution
  end
end

end