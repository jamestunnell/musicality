module Musicality

class MeasureScore
  def pack
    hash = super()
    hash["start_meter"] = start_meter.to_s
    hash["meter_changes"] = Hash[ meter_changes.map do |offset,change|
      a = change.pack
      a[0] = a[0].to_s
      [offset,a]
    end ]
    return hash
  end
  
  def self.unpack packing
    unpacked_start_meter = Meter.parse(packing["start_meter"])
    unpacked_mcs = Hash[ packing["meter_changes"].map do |k,v|
      v = v.clone
      v[0] = Meter.parse(v[0])
      [k, Change.from_ary(v) ]
    end ]
    
    note_score = NoteScore.unpack(packing)
    
    new(unpacked_start_meter, note_score.start_tempo,
      meter_changes: unpacked_mcs, tempo_changes: note_score.tempo_changes,
      program: note_score.program, parts: note_score.parts
    )
  end
end
  
end