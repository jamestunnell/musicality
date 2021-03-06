module Musicality

# Converts tempo-based score to timed score, by converting note-based offsets
# and durations to time-based, and eliminating the use of tempo and meters.
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
        note.resize(endtime - starttime)
      end
      new_dcs = convert_changes(part.dynamic_changes, offset_map)
      new_part = part.clone
      new_part.notes = new_notes
      new_part.dynamic_changes = new_dcs
      [name, new_part]
    end]
  end
  
  def self.convert_program program, offset_map
    program.map do |segment|
      offset_map[segment.first]...offset_map[segment.last]
    end
  end
  
  def initialize score, tempo_sample_rate
    if score.invalid?
      raise NotValidError, "Errors detected given score: #{score.errors}"
    end
    beat_duration_changes = Hash[ score.beat_durations.map do |noff,bdur|
      [noff, Change::Immediate.new(bdur) ]
    end]
    tempo_computer = ValueComputer.new(score.start_tempo, score.tempo_changes)
    bdur_computer = ValueComputer.new(score.start_meter.beat_duration, beat_duration_changes)
    ntc = NoteTimeConverter.new(tempo_computer, bdur_computer, tempo_sample_rate)

    @parts = Hash[ score.parts.map {|name,part| [name, part.clone] }]
    @program = score.program.clone
    @note_time_map = ntc.note_time_map(note_offsets)
  end
  
  def note_offsets
    noffs = Set.new([0.to_r])
    @parts.values.each do |part|
      noff = 0.to_r
      part.notes.each {|note| noffs.add(noff += note.duration) }
      part.dynamic_changes.each {|noff2,change| noffs += change.offsets(noff2) }
    end
    noffs += @program.map {|seg| [seg.first, seg.last] }.flatten
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

end