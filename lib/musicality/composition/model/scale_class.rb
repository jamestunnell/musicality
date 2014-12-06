module Musicality

class ScaleClass
  include Enumerable
  
  def initialize intervals
    if intervals.detect {|x| x <= 0 }
      raise NonPositiveError, "One or more scale intervals (#{intervals}) is non-positive"
    end
    @intervals = intervals
  end
  
  def intervals; self.entries; end
  
  def ==(other)
    self.entries == other.entries
  end
  
  def each
    return @intervals.each unless block_given?
    @intervals.each {|x| yield x }
  end
  
  def to_scale_sequence start_pitch
    Sequence::Adding.new(@intervals, start_pitch)
  end
  
  def rotate n = 1
    ScaleClass.new(@intervals.rotate(n))
  end
end

end
