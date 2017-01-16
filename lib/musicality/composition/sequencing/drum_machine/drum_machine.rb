module Musicality

class DrumMachine < Sequencer
  def initialize drum_patterns
    raise ArgumentError if drum_patterns.empty?

    prev_durations = []
    existing_part_notes = {}
    drum_patterns.each do |drum_pattern|
      durations = drum_pattern.part_notes.values.map do |notes|
        notes.inject(0) {|sum, note| sum + note.duration }
      end
      if durations.uniq.size != 1
        raise ArgumentError, "Drum pattern has part notes of differing total duration #{drum_pattern}"
      end
      duration = durations.first
      if duration <= 0
        raise ArgumentError, "Drum pattern has non-positive part notes"
      end

      drum_pattern.part_notes.each do |part_name, notes|
        # Create part with rest notes from all the previous patterns durations
        unless existing_part_notes.has_key?(part_name)
          existing_part_notes[part_name] = prev_durations.map { |d| Note.new(d) }
        end

        existing_part_notes[part_name] += notes
      end

      # For parts that exist previously but not in the current drum pattern, add a rest note
      existing_part_notes.each do |part_name, notes|
        unless drum_pattern.part_notes.has_key?(part_name)
          existing_part_notes[part_name].push Note.new(duration)
        end
      end

      prev_durations.push duration
    end

    part_sequenceables = Hash[ existing_part_notes.map do |part_name, note_array|
      [ part_name, NoteArray.new(note_array) ]
    end]

    super(part_sequenceables)
  end

  def make_empty_parts drum_kit, part_dynamics = {}
    Hash[ part_names.map do |part_name|
      unless drum_kit.part_settings.has_key?(part_name)
        raise ArgumentError, "Drum kit does not have settings for part: #{part_name}"
      end
      part_dynamic = part_dynamics.has_key?(part_name) ? part_dynamics[part_name] : Dynamics::MF
      part = Part.new(part_dynamic, settings: [drum_kit.part_settings[part_name]])
      [ part_name, part ]
    end]
  end
end

end
