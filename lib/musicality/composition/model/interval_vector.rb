require 'set'

module Musicality

class IntervalVector < Array
  def initialize intervals
    raise ArgumentError, "intervals is empty" if intervals.empty?
    super(intervals)
  end
  
  def invert
    self.class.new map {|interval| -interval }
  end

  def shift offset
    self.class.new map {|int| offset + int }
  end
  
  def to_pitches base_pitch
    map {|int| base_pitch.transpose(int) }
  end
  
  #def to_pcs base_pc
  #  map {|int| base_pc + int }.to_pcs
  #end
end

end

class Array
  def to_iv
    Music::Composition::IntervalVector.new(self.entries)
  end
end