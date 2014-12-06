module Musicality

class ScaleClass
  include Enumerable
  
  def initialize intervals
    @intervals = intervals
    sum = intervals.inject(0,:+)
    
    if intervals.detect {|x| x <= 0 }
      raise NonPositiveError, "One or more scale intervals (#{intervals}) is non-positive"
    end
    
    unless sum == 12
      raise ArgumentError, "intervals (#{intervals}) do not sum 12"
    end
  end
  
  def intervals; self.entries; end
  
  def ==(other)
    self.entries == other.entries
  end
  
  def each
    return @intervals.each unless block_given?
    @intervals.each {|x| yield x }
  end
  
  def to_pcs start_pc
    IntervalArray::Relative.new(@intervals).to_pcs(start_pc).rotate(-1)
  end
  
  def rotate n = 1
    ScaleClass.new(@intervals.rotate(n))
  end
end

end
