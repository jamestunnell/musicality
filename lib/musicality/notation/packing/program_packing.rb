module Musicality

class Program
  def pack
    @segments.map do |seg|
      seg.to_s
    end
  end
  
  def self.unpack packing
    segments = packing.map {|str| Segment.parse(str) }
    new segments
  end
end

end