require 'set'

module Musicality

# Converts unmeasured score to timed score, by converting note-based offsets
# and durations to time-based, and eliminating the use of tempo.
class UnmeasuredScoreConverter

  def initialize score, tempo_sample_rate
    unless score.valid?
      raise NotValidError, "The given score can not be converted because \
                            it is invalid, with these errors: #{score.errors}"
    end
    
    @score = score
    @note_time_map = score.note_time_map(tempo_sample_rate)
  end
  
  def convert_score
    Score::Timed.new(parts: convert_parts, program: convert_program)
  end
  
  # Convert note-based offsets & durations to time-based.
  def convert_parts
    Hash[ @score.parts.map do |name,part|
      offset = 0.to_r
      
      new_notes = part.notes.map do |note|
        starttime = @note_time_map[offset]
        endtime = @note_time_map[offset + note.duration]
        offset += note.duration
        newnote = note.clone
        newnote.duration = endtime - starttime
        newnote
      end
      
      new_dcs = Hash[ part.dynamic_changes.map do |noff,change|
        case change
        when Change::Immediate
          [@note_time_map[noff],change.clone]
        when Change::Gradual
          toff1, toff2, toff3, toff4 = change.offsets(noff).map {|x| @note_time_map[x] }
          [toff2, Change::Gradual.new(change.value,
            toff3-toff2, toff2-toff1, toff4-toff3)]
        end
      end ]
      
      [name, Part.new(part.start_dynamic,
        notes: new_notes, dynamic_changes: new_dcs)]
    end]
  end
  
  # Convert note-based offsets & durations to time-based.
  def convert_program
    newsegments = @score.program.segments.map do |segment|
      first = @note_time_map[segment.first]
      last = @note_time_map[segment.last]
      first...last
    end
    Program.new(newsegments)
  end
end

end
