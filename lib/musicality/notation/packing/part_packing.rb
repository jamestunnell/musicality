module Musicality

class Part
  def pack
    packed_notes = notes.map {|n| n.to_s }.join(" ")
    packed_dcs = Hash[ dynamic_changes.map do |offset,change|
      [ offset, change.pack ]
    end ]
    packed_instr = instrument.pack

    {
      'notes' => packed_notes,
      'start_dynamic' => start_dynamic,
      'dynamic_changes' => packed_dcs,
      'instrument' => packed_instr,
    }
  end
  
  def self.unpack packing
    unpacked_notes = Note.split_parse(packing["notes"])
    unpacked_dcs = Hash[ packing["dynamic_changes"].map do |offset,change|
      [ offset,Change.unpack(change) ]
    end ]
    
    # instrument may not be present in older parts
    instr = packing.has_key?('instrument') ? 
      Instrument.unpack(packing['instrument']) : Instruments::DEFAULT_INSTRUMENT

    new(
      packing["start_dynamic"],
      notes: unpacked_notes,
      dynamic_changes: unpacked_dcs,
      instrument: instr
    )
  end
end

end