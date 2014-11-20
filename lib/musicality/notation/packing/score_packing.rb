module Musicality

class Score
  class Unmeasured < Score
    def pack
      pack_common
    end
    
    def self.unpack packing
      score = Score.unpack_common(packing)
      new(score.start_tempo, program: score.program,
        tempo_changes: score.tempo_changes, parts: score.parts)
    end
  end
  
  class Measured < Score
    def pack
      packing = pack_common
      packing["start_meter"] = start_meter.to_s
      packing["meter_changes"] = Hash[ meter_changes.map do |off,change|
        [off,change.pack.merge("value" => change.value.to_s)]
      end ]
      return packing
    end
    
    def self.unpack packing
      score = Score.unpack_common(packing)
      unpacked_start_meter = Meter.parse(packing["start_meter"])
      unpacked_mcs = Hash[ packing["meter_changes"].map do |off,p|
        [off, Change.unpack(p.merge("value" => Meter.parse(p["value"]))) ]
      end ]
      
      new(unpacked_start_meter, score.start_tempo,
          parts: score.parts, program: score.program,
          meter_changes: unpacked_mcs, tempo_changes: score.tempo_changes)
    end
  end
  
  def self.unpack packing
    type = const_get(packing["type"])
    type.unpack(packing)
  end
  
  private
  
  def pack_common
    packed_tcs = Hash[ tempo_changes.map do |offset,change|
      [offset,change.pack]
    end ]

    packed_parts = Hash[
      @parts.map do |name,part|
        [ name, part.pack ]
      end
    ]
    packed_prog = program.pack
    
    { "type" => self.class.to_s.split("::")[-1],
      "start_tempo" => @start_tempo,
      "tempo_changes" => packed_tcs,
      "program" => packed_prog,
      "parts" => packed_parts,
    }
  end
  
  def self.unpack_common packing
    unpacked_tcs = Hash[ packing["tempo_changes"].map do |k,v|
      [k, Change.unpack(v) ]
    end ]
    
    unpacked_parts = Hash[ packing["parts"].map do |name,packed|
      [name, Part.unpack(packed)]
    end ]
    
    unpacked_prog = Program.unpack packing["program"]
    
    new(packing["start_tempo"],
      tempo_changes: unpacked_tcs,
      program: unpacked_prog,
      parts: unpacked_parts
    )
  end
end

end