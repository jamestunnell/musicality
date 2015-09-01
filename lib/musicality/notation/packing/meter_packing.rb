module Musicality

class Meter
  def pack
    { "beats_per_measure" => @beats_per_measure,
      "beat_duration" => beat_duration }
  end

  def self.unpack packing
    if packing.is_a? String # old packings may be strings
      return packing.to_meter
    else
      return Meter.new(packing["beats_per_measure"],
        packing["beat_duration"])
    end
  end
end

end