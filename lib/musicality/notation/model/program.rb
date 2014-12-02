module Musicality

# Program defines markers (by starting note offset) and subprograms (list which markers are played).
#
# @author James Tunnell
#
class Program < Array
  include Validatable
  
  def initialize *segments
    if segments.size == 1 && segments[0].is_a?(Array)
      super segments[0]
    else
      super(segments)
    end
  end
  
  def segments; entries; end
  
  def check_methods
    [:ensure_ranges, :ensure_increasing_segments, :ensure_nonnegative_segments]
  end
  
  # @return [Float] the sum of all program segment lengths
  def length
    inject(0.0) { |length, segment| length + (segment.last - segment.first) }
  end

  def include_offset? offset
    !detect {|seg| seg.include?(offset) }.nil?
  end
  
  private
  
  def ensure_ranges
    non_ranges = select{|x| !x.is_a?(Range) }
    if non_ranges.any?
      raise TypeError, "Non-Range element(s) found: #{non_ranges}"
    end
  end
  
  def ensure_increasing_segments
    non_increasing = select {|seg| seg.first >= seg.last }
    if non_increasing.any?
      raise NonIncreasingError, "Non-increasing range(s) found: #{non_increasing}"
    end
  end
  
  def ensure_nonnegative_segments
    negative = select {|seg| seg.first < 0 || seg.last < 0 }
    if negative.any?
      raise NegativeError, "Range(s) with negative value(s) found: #{negative}"
    end
  end
end

end

class Array
  def to_program
    Musicality::Program.new(*entries)
  end
end