module Musicality

module DrumPatterns
  POP_1 = DrumPattern.new(1,
    DrumParts::ACCENT => [-4,1,-7,1,-3],
    DrumParts::CLOSED_HI_HAT => [1,-1] * 8,
    DrumParts::SNARE_DRUM => [-4,1,-7,1,-3],
    DrumParts::BASS_DRUM => [1,1,-1,1,-1,1,-1,1,1,1,-1,1,-1,1,-1,1]
  )

  POP_2 = DrumPattern.new(1,
    DrumParts::ACCENT => [-4,1,-7,1,-3],
    DrumParts::CLOSED_HI_HAT => [1,-1] * 8,
    DrumParts::SNARE_DRUM => [-4,1,-7,1,-3],
    DrumParts::BASS_DRUM => [1,-1,1,-2,1,1,1,1,-1,1,-2,1,1,1]
  )

  POP_3 = DrumPattern.new(1,
    DrumParts::ACCENT => [-4,1,-7,1,-3],
    DrumParts::CLOSED_HI_HAT => [1,-1,1,-1,1,-2,1,1,-1,1,-1,1,-2,1],
    DrumParts::SNARE_DRUM => [-4,1,-7,1,-3],
    DrumParts::BASS_DRUM => [1,1,-1,1,-1,1,-2,1,1,-1,1,-4]
  )

  POP_4 = DrumPattern.new(1,
    DrumParts::ACCENT => [-4,1,-7,1,-3],
    DrumParts::CLOSED_HI_HAT => [1,-1] * 8,
    DrumParts::SNARE_DRUM => [-4,1,-7,1,-3],
    DrumParts::BASS_DRUM => [1,-1,1,1,-1,1,-1,1,-1,1,-1,1,-1,1,-1,1]
  )


  POP_5 = DrumPattern.new(1,
    DrumParts::ACCENT => [-4,1,-7,1,-3],
    DrumParts::CLOSED_HI_HAT => [1,-1] * 8,
    DrumParts::SNARE_DRUM => [-4,1,-7,1,-3],
    DrumParts::BASS_DRUM => [1,1,-1,1,-4,1,1,-1,1,-2,1,1]
  )


  POP_6 = DrumPattern.new(1,
    DrumParts::ACCENT => [-4,1,-7,1,-3],
    DrumParts::CLOSED_HI_HAT => [1,-1] * 8,
    DrumParts::SNARE_DRUM => [-4,1,-7,1,-3],
    DrumParts::BASS_DRUM => [1,1,-1,1,-4,1,1,-1,1,-4]
  )

  POP_7 = DrumPattern.new(1,
    DrumParts::ACCENT => [-4,1,-7,1,-3],
    DrumParts::CLOSED_HI_HAT => [1,-1,1,-3,1,-1,1,-1,1,-3,1,-1],
    DrumParts::OPEN_HI_HAT => [-4,1,-7,1,-3],
    DrumParts::SNARE_DRUM => [-4,1,-7,1,-3],
    DrumParts::BASS_DRUM => [1,-1,1,1,-2,1,-3,1,1,-2,1,-1]
  )

  POP_8 = DrumPattern.new(1,
    DrumParts::ACCENT => [-4,1,-7,1,-3],
    DrumParts::CLOSED_HI_HAT => [1,-3,1,-3,1,-3,1,-3],
    DrumParts::OPEN_HI_HAT => [-2,1,-3,1,-3,1,-3,1,-1],
    DrumParts::SNARE_DRUM => [-4,1,-7,1,-3],
    DrumParts::BASS_DRUM => [1,-1,1,-3,1,-3,1,-3,1,-1]
  )

  POP_9 = DrumPattern.new(1,
    DrumParts::ACCENT => [-6,1,-5,1,-3],
    DrumParts::CLOSED_HI_HAT => [1,-1,1,-1,1,-1,1,-1,1,-3,1,-3],
    DrumParts::OPEN_HI_HAT => [-10,1,-3,1,-1],
    DrumParts::SNARE_DRUM => [-6,1,-5,1,-1,1,-1],
    DrumParts::BASS_DRUM => [1,-1,1,-7,1,-5]
  )

  POP_10 = DrumPattern.new(1,
    DrumParts::ACCENT => [-4,1,-7,1,-3],
    DrumParts::CLOSED_HI_HAT => [1]*12 + [-4],
    DrumParts::OPEN_HI_HAT => [-13,1,-1,1],
    DrumParts::SNARE_DRUM => [-4,1,-2,1,-4,1,-3],
    DrumParts::BASS_DRUM => [1,-1,1,-5,1,1,-1,1,-1,1,-1,1]
  )

  POP_11 = DrumPattern.new(1,
    DrumParts::ACCENT => [-4,1,-7,1,-3],
    DrumParts::CLOSED_HI_HAT => [-1,1,1,1]*4,
    DrumParts::SNARE_DRUM => [1,-3,1,-3,1,-3,1,-3],
    DrumParts::BASS_DRUM => [-2,1,-2,1,-1,1,-2,1,-2,1,-1,1]
  )

  POP_12 = DrumPattern.new(1,
    DrumParts::ACCENT => [-4,1,-7,1,-3],
    DrumParts::CLOSED_HI_HAT => ([1]*4 + [-1,1,-1,1])*2,
    DrumParts::OPEN_HI_HAT => [-6,1,-7,1,-1],
    DrumParts::SNARE_DRUM => [-4,1,-7,1,-3],
    DrumParts::BASS_DRUM => [1,-1,1,-4,1,1,-1,1,-4,1]
  )

  POP_BREAK_1 = DrumPattern.new(1,
    DrumParts::HI_TOM => [-8,1,1,-1,1,-4],
    DrumParts::MED_TOM => [-4,1,-2,1,-8],
    DrumParts::LOW_TOM => [-12,1,1,1,-1],
    DrumParts::SNARE_DRUM => [1,1,1,1,-12],
    DrumParts::BASS_DRUM => [1,1,-6,1,-7],
  )

  POP_BREAK_2 = DrumPattern.new(1,
    DrumParts::ACCENT => [1,-2] * 5 + [-1],
    DrumParts::HI_TOM => [-6,1,-9],
    DrumParts::MED_TOM => [-3,1,-12],
    DrumParts::LOW_TOM => [-9,1,-6],
    DrumParts::SNARE_DRUM => [1,-11,1,-3],
    DrumParts::BASS_DRUM => [-1,1,1] * 5 + [1],
  )

  POP_BREAK_3 = DrumPattern.new(1,
    DrumParts::CRASH_CYMBAL => [1,-15],
    DrumParts::HI_TOM => [-13,1,1,1],
    DrumParts::MED_TOM => [-8,1,1,-1,1,-4],
    DrumParts::SNARE_DRUM => [-2,1,-3,1,-9],
    DrumParts::BASS_DRUM => [1,-7,1,-7],
  )

  POP_BREAK_4 = DrumPattern.new(1,
    DrumParts::ACCENT => [-4,1,-7,1,-3],
    DrumParts::SNARE_DRUM => [-4,1,-4,1,1,-1,1,-3],
    DrumParts::BASS_DRUM => [1,-1,1,-2,1,-1,1,-3,1,-4],
  )

  POP_BREAK_5 = DrumPattern.new(1,
    DrumParts::CRASH_CYMBAL => [-12,1,1,-2],
    DrumParts::MED_TOM => [-3,1,-12],
    DrumParts::LOW_TOM => [-6,1,-9],
    DrumParts::SNARE_DRUM => [1,-8,1,-6],
    DrumParts::BASS_DRUM => [-12,1,1,-2],
  )

  POP_BREAK_6 = DrumPattern.new(1,
    DrumParts::ACCENT => [1,-2,1,1,-2,1,-6,1,-1],
    DrumParts::CRASH_CYMBAL => [1,-15],
    DrumParts::CLOSED_HI_HAT => [-7,1,-8],
    DrumParts::OPEN_HI_HAT => [-13,1,-1],
    DrumParts::MED_TOM => [-4,1,1,1,-9],
    DrumParts::LOW_TOM => [-11,1,1,1,-1],
    DrumParts::SNARE_DRUM => [-1,1,1,1,-5,1,1,-5],
    DrumParts::BASS_DRUM => [1,-6,1,-8],
  )
end

end
