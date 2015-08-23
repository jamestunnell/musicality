module Musicality

class Instrument
  def pack
    { 'name' => @name, 'clefs' => @clefs, 'midi_num' => @midi_num, 
      'transpose_interval' => @transpose_interval }
  end

  def self.unpack packing
    Instrument.new(packing['name'], packing['clefs'],
      packing['midi_num'], packing['transpose_interval'])
  end
end

end