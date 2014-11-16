module Musicality

class Part
  def pack
    packed_notes = notes.map {|n| n.to_s }.join(" ")
    packed_dcs = Hash[ dynamic_changes.map do |offset,change|
      [ offset, change.pack ]
    end ]
      
    {
      'notes' => packed_notes,
      'start_dynamic' => start_dynamic,
      'dynamic_changes' => packed_dcs
    }
  end
  
  def self.unpack packing
    unpacked_notes = Note.split_parse(packing["notes"])
    unpacked_dcs = Hash[ packing["dynamic_changes"].map do |offset,change|
      [ offset,Change.unpack(change) ]
    end ]
    
    new(
      packing["start_dynamic"],
      notes: unpacked_notes,
      dynamic_changes: unpacked_dcs
    )
  end
end

end