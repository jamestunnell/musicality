module Musicality

class Key
  def pack
    { "tonic_pc" => @tonic_pc, "triad" => @triad, "accidental_pref" => @accidental_pref }
  end

  def self.unpack packing
    Key.new(packing["tonic_pc"], 
      triad: packing["triad"], accidental_pref: packing["accidental_pref"])
  end
end

end
