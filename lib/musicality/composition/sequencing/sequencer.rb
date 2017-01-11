module Musicality

class Sequencer
  attr_reader :part_sequenceables
  
  def initialize part_sequenceables
    @part_sequenceables = part_sequenceables.freeze
    @part_note_fifos = Hash[ part_sequenceables.keys.map {|partname| [ partname, NoteFIFO.new ] } ]
  end

  def next_part_notes target_duration
    if target_duration <= 0
      raise ArgumentError, "Target duration #{target_duration} is non-positive}"
    end
    part_notes = {}

    @part_sequenceables.each do |partname, sequenceable|
      note_fifo = @part_note_fifos[partname]

      while note_fifo.duration < target_duration
        note_fifo.add_note(sequenceable.next_note)
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
