module Musicality

class NoteScore
  def pack
    packed_starttempo = start_tempo.to_s
    packed_tcs = Hash[ tempo_changes.map do |offset,change|
      a = change.pack
      a[0] = a[0].to_s
      [offset,a]
    end ]

    packed_parts = Hash[
      @parts.map do |name,part|
        [ name, part.pack ]
      end
    ]
    packed_prog = program.pack
    
    { "start_tempo" => packed_starttempo,
      "tempo_changes" => packed_tcs,
      "program" => packed_prog,
      "parts" => packed_parts,
    }
  end
  
  def self.unpack packing
    unpacked_starttempo = Tempo.parse(packing["start_tempo"])
    unpacked_tcs = Hash[ packing["tempo_changes"].map do |k,v|
      v = v.clone
      v[0] = Tempo.parse(v[0])
      [k, Change.from_ary(v) ]
    end ]
    
    unpacked_parts = Hash[ packing["parts"].map do |name,packed|
      [name, Part.unpack(packed)]
    end ]
    
    unpacked_prog = Program.unpack packing["program"]
    
    new(unpacked_starttempo,
      tempo_changes: unpacked_tcs,
      program: unpacked_prog,
      parts: unpacked_parts
    )
  end
end
  
end