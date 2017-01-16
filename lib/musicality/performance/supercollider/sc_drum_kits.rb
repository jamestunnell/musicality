module Musicality

module DrumKits

SC_DRUM_KIT_01 = DrumKit.new(
  DrumParts::BASS_DRUM => SuperCollider::SynthDefs::KICK2.settings,
  DrumParts::SNARE_DRUM => SuperCollider::SynthDefs::SNARE_STEIN.settings,
  DrumParts::CRASH_CYMBAL => SuperCollider::SynthDefs::CYMBALIC_MCLD.settings,
  DrumParts::CLOSED_HI_HAT => SuperCollider::SynthDefs::CLOSED_HAT.settings,
  DrumParts::OPEN_HI_HAT => SuperCollider::SynthDefs::OPEN_HAT.settings,
  DrumParts::HI_TOM => SuperCollider::SynthDefs::TOM1.settings,
  DrumParts::MED_TOM => SuperCollider::SynthDefs::TOM1.settings,
  DrumParts::LOW_TOM => SuperCollider::SynthDefs::TOM1.settings,
)

SC_DRUM_KIT_02 = DrumKit.new(
  DrumParts::BASS_DRUM => SuperCollider::SynthDefs::KICK_CHIRP.settings,
  DrumParts::SNARE_DRUM => SuperCollider::SynthDefs::SNARE1.settings,
  DrumParts::CRASH_CYMBAL => SuperCollider::SynthDefs::CYMBALIC_MCLD.settings,
  DrumParts::CLOSED_HI_HAT => SuperCollider::SynthDefs::HIHAT1.settings,
  DrumParts::OPEN_HI_HAT => SuperCollider::SynthDefs::HIHAT1.settings(:release => 0.6),
  DrumParts::HI_TOM => SuperCollider::SynthDefs::FM_TOM.settings,
  DrumParts::MED_TOM => SuperCollider::SynthDefs::FM_TOM.settings,
  DrumParts::LOW_TOM => SuperCollider::SynthDefs::FM_TOM.settings,
)

end

end
