module Musicality

class DrumMachine < Sequencer
  def initialize drum_patterns
    raise ArgumentError if drum_patterns.empty?

    prev_durations = []
    part_note_arrays = {}
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
        unless part_note_arrays.has_key?(part_name)
          part_note_arrays[part_name] = prev_durations.map { |d| Note.new(d) }
        end
        part_note_arrays[part_name] += notes
      end

      prev_durations.push duration
    end

    part_sequenceables = Hash[ part_note_arrays.map do |part_name, note_array|
      [ part_name, NoteArray.new(note_array) ]
    end]

    super(part_sequenceables)
  end
end

end
