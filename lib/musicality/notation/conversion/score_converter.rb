module Musicality

class ScoreConverter
  def self.convert_changes changes, offset_map
    Hash[ changes.map do |off,change|
      [ offset_map[off], change.remap(off,offset_map) ]
    end ]    
  end
  
  def self.convert_parts parts, offset_map
    Hash[ parts.map do |name,part|
      offset = 0.to_r
      new_notes = part.notes.map do |note|
        starttime = offset_map[offset]
        endtime = offset_map[offset + note.duration]
        offset += note.duration
        newnote = note.clone
        newnote.duration = endtime - starttime
        newnote
      end
      new_dcs = convert_changes(part.dynamic_changes, offset_map)
      [name, Part.new(part.start_dynamic,
        notes: new_notes, dynamic_changes: new_dcs)]
    end]
  end
  
  def self.convert_program program, offset_map
    program.map do |segment|
      offset_map[segment.first]...offset_map[segment.last]
    end.to_program
  end
  
  class TempoBased
    def initialize parts, program, note_time_converter
      @parts = parts
      @program = program
      @note_time_map = note_time_converter.note_time_map(note_offsets)
    end
    
    def note_offsets
      noffs = Set.new([0.to_r])
      @parts.values.each do |part|
        noff = 0.to_r
        part.notes.each {|note| noffs.add(noff += note.duration) }
        part.dynamic_changes.each {|noff2,change| noffs += change.offsets(noff2) }
      end
      noffs += @program.segments.map {|seg| [seg.first, seg.last] }.flatten
      return noffs.sort
    end

    def convert_score
      Score::Timed.new(parts: convert_parts, program: convert_program)
    end
  
    # Convert note-based offsets & durations to time-based.
    def convert_parts
      ScoreConverter.convert_parts(@parts, @note_time_map)
    end
    
    # Convert note-based offsets & durations to time-based.
    def convert_program
      ScoreConverter.convert_program(@program, @note_time_map)
    end
  end
  
  # Converts unmeasured score to timed score, by converting note-based offsets
  # and durations to time-based, and eliminating the use of tempo.
  class Unmeasured < TempoBased
    def initialize score, tempo_sample_rate
      if score.invalid?
        raise NotValidError, "Errors detected given score: #{score.errors}"
      end
      tempo_computer = ValueComputer.new(score.start_tempo, score.tempo_changes)
      ntc = NoteTimeConverter::Unmeasured.new(tempo_computer, tempo_sample_rate)
      super(score.parts, score.program, ntc)
    end
  end
  
  # Converts measured score to timed score, by converting note-based offsets
  # and durations to time-based, and eliminating the use of tempo and meters.
  class Measured < TempoBased
    def initialize score, tempo_sample_rate
      if score.invalid?
        raise NotValidError, "Errors detected given score: #{score.errors}"
      end
      mn_map = score.measure_note_map
      new_parts = Hash[ score.parts.map do |name,part|
        new_dcs = ScoreConverter.convert_changes(part.dynamic_changes, mn_map)
        new_notes = part.notes.map {|n| n.clone } # note duration is already note-based
        [name, Part.new(part.start_dynamic, notes: new_notes, dynamic_changes: new_dcs)]
      end]      
      new_program = ScoreConverter.convert_program(score.program, mn_map)
      new_tempo_changes = ScoreConverter.convert_changes(score.tempo_changes, mn_map)
      new_beat_durations = Hash[ score.beat_durations.map do |moff,bdur|
        [mn_map[moff], Change::Immediate.new(bdur) ]
      end]
      tempo_computer = ValueComputer.new(score.start_tempo, new_tempo_changes)
      bdur_computer = ValueComputer.new(score.start_meter.beat_duration, new_beat_durations)
      ntc = NoteTimeConverter::Measured.new(tempo_computer, bdur_computer, tempo_sample_rate)
      super(new_parts, new_program, ntc)
    end
  end
end

end