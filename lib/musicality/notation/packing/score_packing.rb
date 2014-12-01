module Musicality

class Score
  class Timed < Score
    def pack
      pack_common
    end
    
    def self.unpack packing
      score = Score.unpack_common(packing)
      new(parts: score.parts, program: score.program)
    end
  end
  
  class TempoBased < Score
    def pack
      packed_tcs = Hash[ tempo_changes.map do |offset,change|
        [offset,change.pack]
      end ]
      
      pack_common.merge("start_tempo" => @start_tempo,
        "tempo_changes" => packed_tcs)
    end
    
    def self.unpack packing
      score = Score.unpack_common(packing)
      
      unpacked_tcs = Hash[ packing["tempo_changes"].map do |k,v|
        [k, Change.unpack(v) ]
      end ]
      
      new(packing["start_tempo"],
        tempo_changes: unpacked_tcs,
        program: score.program,
        parts: score.parts
      )
    end    
  end
  
  class Unmeasured < TempoBased
    def pack
      super()
    end
    
    def self.unpack packing
      score = superclass.unpack(packing)
      new(score.start_tempo, program: score.program,
        tempo_changes: score.tempo_changes, parts: score.parts)
    end
  end
  
  class Measured < TempoBased
    def pack
      return super().merge("start_meter" => start_meter.to_s,
        "meter_changes" => Hash[ meter_changes.map do |off,change|
          [off,change.pack(:with => :to_s)]
        end ]
      )
    end
    
    def self.unpack packing
      score = superclass.unpack(packing)
      unpacked_start_meter = Meter.parse(packing["start_meter"])
      unpacked_mcs = Hash[ packing["meter_changes"].map do |off,p|
         [off, Change.unpack(p, :with => :to_meter) ]
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
    packed_parts = Hash[
      @parts.map do |name,part|
        [ name, part.pack ]
      end
    ]
    packed_prog = program.pack
    
    { "type" => self.class.to_s.split("::")[-1],
      "program" => packed_prog,
      "parts" => packed_parts,
    }
  end
  
  def self.unpack_common packing
    unpacked_parts = Hash[ packing["parts"].map do |name,packed|
      [name, Part.unpack(packed)]
    end ]
    
    unpacked_prog = Program.unpack packing["program"]
    
    new(program: unpacked_prog,
      parts: unpacked_parts
    )
  end    
end

end