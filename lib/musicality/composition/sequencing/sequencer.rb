module Musicality

class Sequencer
  class NotesFIFO
    attr_reader :notes, :duration
    def initialize initial_notes = []
      @notes = []
      @duration = 0
      add_notes(initial_notes) if initial_notes.any?
    end

    def empty?
      @notes.empty?
    end

    def add_notes notes
      nonpositive = notes.select {|x| x.duration <= 0}
      if nonpositive.any?
        raise ArgumentError, "one or more notes have non-positive duration: #{notes}"
      end
      @notes += notes
      @duration += notes.inject(0) {|sum, note| sum + note.duration }
    end

    # Return a sequence of notes with total duration equal to the given target duration, and remove
    # the same notes from the accumulator. Any notes beyond the given target duration are left in
    # the accumulator. Split a note into two tied notes if needed.
    def remove_notes target_duration
      raise ArgumentError, "negative target duration #{target_duration}" if target_duration < 0

      if target_duration > duration
        raise ArgumentError, "target duration #{target_duration} is greater than duration of accumulated notes #{duration}"
      end

      removed_notes = if target_duration == 0
        []
      elsif target_duration == duration
        notes.shift(notes.size)
      else
        dur_so_far = 0.to_r
        num_notes_taking = 0
        @notes.each_with_index do |note, idx|
          dur_so_far += note.duration
          num_notes_taking += 1
          break if dur_so_far >= target_duration
        end

        notes_taking = notes.shift(num_notes_taking)
        excess_dur = dur_so_far - target_duration

        if excess_dur > 0
          @notes.unshift(notes_taking[-1].resize(excess_dur))
          notes_taking[-1] = notes_taking[-1].resize(notes_taking[-1].duration - excess_dur)
          notes_taking[-1].pitches.each do |pitch|
            notes_taking[-1].links[pitch] = Link::Tie.new
          end
        end
        notes_taking
      end

      @duration = @duration - target_duration
      return removed_notes
    end
  end

  def initialize part_sequenceables
    @part_sequenceables = part_sequenceables
    @part_note_fifos = Hash[ part_sequenceables.keys.map {|partname| [ partname, NotesFIFO.new ] } ]
  end

  def next_part_notes target_duration
    raise ArgumentError if target_duration <= 0
    part_notes = {}

    @part_sequenceables.each do |partname, sequenceable|
      note_fifo = @part_note_fifos[partname]

      while note_fifo.duration < target_duration
        note_fifo.add_notes(sequenceable.next_notes)
      end
      part_notes[partname] = note_fifo.remove_notes(target_duration)
    end

    return part_notes
  end

  def reset
    @part_sequenceables.values.each { |s| s.reset }
  end
end

end
