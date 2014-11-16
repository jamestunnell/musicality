module Musicality

# Program defines markers (by starting note offset) and subprograms (list which markers are played).
#
# @author James Tunnell
#
class Program
  include Validatable
  
  attr_accessor :segments
  
  def initialize segments = []
    @segments = segments
  end

  def check_methods
    [:ensure_increasing_segments, :ensure_nonnegative_segments]
  end
  
  # @return [Float] the sum of all program segment lengths
  def length
    segments.inject(0.0) { |length, segment| length + (segment.last - segment.first) }
  end
  
  def == other
    return other.respond_to?(:segments) && @segments == other.segments
  end

  def include? offset
    @segments.each do |segment|
      if segment.include?(offset)
        return true
      end
    end
    return false
  end
  
  def ensure_increasing_segments
    non_increasing = @segments.select {|seg| seg.first >= seg.last }
    if non_increasing.any?
      raise NonIncreasingError, "Non-increasing segments found #{non_increasing}"
    end
  end
  
  def ensure_nonnegative_segments
    negative = @segments.select {|seg| seg.first < 0 || seg.last < 0 }
    if negative.any?
      raise NegativeError, "Segments #{negative} have negative values"
    end
  end
end

end
