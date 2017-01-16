module Musicality

module DrumParts
  ACCENT = "AC"
  CRASH_CYMBAL = "CCY"
  RIDE_CYMBAL = "RCY"
  CLOSED_HI_HAT = "CH"
  OPEN_HI_HAT = "OH"
  HI_TOM = "HT"
  MED_TOM = "MT"
  LOW_TOM = "LT"
  SNARE_DRUM = "SD"
  RIM_SHOT = "RS"
  CLAPS = "CPS"
  COW_BELL = "CB"
  BASS_DRUM = "BD"
end

DRUM_PARTS = DrumParts.constants.map { |sym| DrumParts.const_get(sym) }

end
