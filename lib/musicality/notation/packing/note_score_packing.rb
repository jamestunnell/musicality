module Musicality

class NoteScore
  def pack
    packed_tcs = Hash[ tempo_changes.map do |offset,change|
      [offset,change.pack]
    end ]

    packed_parts = Hash[
      @parts.map do |name,part|
        [ name, part.pack ]
      end
    ]
    packed_prog = program.pack
    
    { "start_tempo" => @start_tempo,
      "tempo_changes" => packed_tcs,
      "program" => packed_prog,
      "parts" => packed_parts,
    }
  end
  
  def self.unpack packing
    unpacked_tcs = Hash[ packing["tempo_changes"].map do |k,v|
      [k, Change.from_ary(v) ]
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