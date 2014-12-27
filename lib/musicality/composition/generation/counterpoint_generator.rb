module Musicality

class CounterpointGenerator
  attr_reader :rhythm, :palette, :total_dur, :solution_classes, :solutions
  def initialize rhythm, palette, max_fact = 5
    raise ArgumentError, "max_fact must be >= palette size" if max_fact < palette.size
    
    @rhythm = rhythm
    @palette = palette
    @total_dur = rhythm.map {|dur| dur.abs }.inject(0,:+)
    @solution_classes = self.class.solution_classes(@total_dur, @palette)
    @solution_classes.keep_if do |sc|
      sc.map {|k,v| k*v}.inject(0,:+) == @total_dur
    end
    @solutions = figure_solutions(max_fact)
  end
  
  def self.rhythm_to_computer rhythm
    rhythm_accum = AddingSequence.new(rhythm).take(rhythm.size+1).to_a
    x = rhythm_accum[0,rhythm.size]
    y = rhythm_accum[1,rhythm.size].map {|y_| Change::Immediate.new(y_) }
    value_changes = Hash[ [x,y].transpose ]
    ValueComputer.new(0, value_changes)
  end
  
  def evaluate solution, sample_rate
    if solution.inject(0,:+) != @total_dur
      raise ArgumentError, "Given solution #{solution} does not have same duration as rhythm"
    end
    
    rhythm_comp = self.class.rhythm_to_computer(@rhythm)
    solution_comp = self.class.rhythm_to_computer(solution)
    
    r = rhythm_comp.sample(0...@total_dur, sample_rate)
    s = solution_comp.sample(0...@total_dur, sample_rate)
    n_same = [r,s].transpose.count {|pair| pair[0] == pair[1] }
    return n_same/sample_rate.to_r
  end
  
  def best_solution sample_rate
    @solutions.min_by {|sol| evaluate(sol,sample_rate) }
  end
  
  private
  
  def figure_solutions max_factorial
    solutions = []
    @solution_classes.each do |sc|
      tot = sc.values.inject(0,:+)
      if tot <= max_factorial
        proto = sc.map {|dur,n| [dur]*n }.flatten
        solutions += proto.permutation(proto.size).to_a.uniq
      else
        durs, counts = sc.sort_by {|k,v| v }.transpose
        self.class.limited_solution_classes(durs,counts,max_factorial).each do |ltd_sc|
          ltd_proto = ltd_sc.map do |dur,ns|
            ns.map {|n| [dur]*n }
          end.flatten(1)
          solutions += ltd_proto.permutation(max_factorial).map do |perm|
            perm.flatten
          end.to_a.uniq
        end
      end
    end
    
    return solutions.uniq
  end
  
  def self.limited_solution_classes durs, counts, max_fact
    n_counts = counts.size
    if n_counts > max_fact
      raise ArgumentError, "counts.size (#{n_counts}) is > max_fact (#{max_fact})"
    end
    
    total_count_rem = counts.inject(0,:+)
    if total_count_rem < max_fact
      raise ArgumentError, "total_count_rem (#{total_count_rem}) <= max_fact (#{max_fact})"
    end
    
    ltd_solns = []
    counts.size.times do |i|
      count, dur = counts.first, durs.first
      counts_rem = counts.drop(1)
      
      adj_count = [ count, max_fact - counts_rem.size ].min
      
      positive_integer_combinations_with_sum(count,adj_count).each do |comb|
        if counts_rem.empty?
          ltd_solns.push(dur => comb)
        else
          max_fact_rem = max_fact - adj_count
          limited_solution_classes(durs.drop(1), counts_rem, max_fact_rem).each do |ltd_soln2|
            ltd_solns.push(ltd_soln2.merge(dur => comb))
          end
        end
      end
      
      counts.rotate!
      durs.rotate!
    end
    return ltd_solns.uniq  
  end
  
  def self.positive_integer_combinations_with_sum sum, n_pos_ints
    raise ArgumentError, "sum must be <= number of positive integers" if n_pos_ints > sum
    
    if n_pos_ints == 1
      return [[sum]]
    elsif sum == n_pos_ints
      return [[1]*n_pos_ints]
    else
      return (1...sum).to_a.combination(n_pos_ints-1).map do |comb|
        prev_post = 0
        diffs = comb.map do |post|
          diff = post - prev_post
          prev_post = post
          diff
        end
        (diffs + [sum-prev_post]).sort
      end.uniq
    end
  end
  
  def self.solution_classes total_dur, palette
    dur = palette.first
    n = (total_dur / dur).to_i
    
    if palette.size == 1
      return [ n > 0 ? {dur => n} : {} ]
    else
      new_palette = palette.drop(1)
      return Array.new(n+1) do |i|
        subs = solution_classes(total_dur - i*dur, new_palette)
        if i > 0
          subs.each{|soln_class| soln_class[dur] = i }
        end
        subs
      end.flatten
    end
  end
end

#rhythm = [1/4.to_r,1/4.to_r,1/8.to_r,1/8.to_r,1/8.to_r,1/8.to_r,1/4.to_r,1/2.to_r]
#palette = [1/8.to_r,1/4.to_r,1/2.to_r]
#cpg = CounterpointGenerator.new(rhythm,palette)

end