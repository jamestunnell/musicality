module Musicality

class Program
  def pack
    map {|seg| seg.to_s }
  end
  
  def self.unpack packing
    packing.map {|str| Segment.parse(str) }.to_program
  end
end

end