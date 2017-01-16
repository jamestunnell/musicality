module Musicality

class DrumPattern
  attr_reader :part_notes, :duration

  DRUM_PART_PITCHES = {
    DrumParts::BASS_DRUM => Pitches::G1,
    DrumParts::SNARE_DRUM => Pitches::G3,
    DrumParts::HI_TOM => Pitches::D3,
    DrumParts::MED_TOM => Pitches::B2,
    DrumParts::LOW_TOM => Pitches::G2,
  }
  DUMMY_PITCH = Pitches::C4

  def initialize duration, part_portions
    @duration = duration

    non_drumpart_names = part_portions.select do |part_name|
      !DRUM_PARTS.include?(part_name)
    end
    if non_drumpart_names.any?
      raise ArgumentError, "Part names used that are not drum parts: #{non_drumpart_names.inspect}"
    end

    accent_offsets = if part_portions.has_key?(DrumParts::ACCENT)
      DrumPattern.determine_accent_offsets(
        part_portions.delete(DrumParts::ACCENT).to_rhythm_class.to_rhythm(duration))
    else
      []
    end

    @part_notes = Hash[ part_portions.map do |part_name, portions|
      pitch = DRUM_PART_PITCHES[part_name] || DUMMY_PITCH
      notes = portions.to_rhythm_class.to_rhythm(duration).to_notes(pitch)
      DrumPattern.apply_accents(notes, accent_offsets)
      [ part_name, notes ]
    end ]
  end

  def self.determine_accent_offsets accent_rhythm
    accent_offsets = []
    cum_dur = 0

    accent_rhythm.durations.each do |dur|
      if dur > 0
        accent_offsets.push cum_dur
      end
      cum_dur += dur
    end

    return accent_offsets
  end

  def self.apply_accents notes, accent_offsets
    cum_dur = 0

    notes.each do |note|
      if note.pitches.any? && accent_offsets.include?(cum_dur)
        note.mark_accented!
      end
      cum_dur += note.duration
    end
  end
end

end
