module Musicality

# Converts MeasureScore to NoteScore by converting measure-based offsets to
# note-based offsets, and eliminating the use of meters. Also, tempo is
# coverted from beats-per-minute to quarter-notes per minute.
class MeasureScoreConverter
  def initialize score
    unless score.valid?
      raise NotValidError, "The given score can not be converted to a NoteScore, because \
                            it is invalid, with these errors: #{score.errors}"
    end
    
    @score = score
    @mnoff_map = score.measure_note_map
  end
  
  def convert_score
    NoteScore.new(convert_start_tempo,
      parts: convert_parts, program: convert_program,
      tempo_changes: convert_tempo_changes)
  end
  
  def convert_parts
    Hash[ @score.parts.map do |name,part|
      new_dcs = Hash[ part.dynamic_changes.map do |moff,change|
        case change
        when Change::Immediate
          [@mnoff_map[moff],change]
        when Change::Gradual
          noff1 = @mnoff_map[moff-change.elapsed]
          noff2 = @mnoff_map[moff]
          noff3 = @mnoff_map[moff+change.duration]
          noff4 = @mnoff_map[moff+change.duration+change.remaining]
          [noff2, Change::Gradual.new(change.value,
            noff3-noff2, noff2-noff1, noff4-noff3)]
        end
      end ]
      new_notes = part.notes.map {|n| n.clone }
      [name, Part.new(part.start_dynamic,
        notes: new_notes, dynamic_changes: new_dcs)]
    end ]
  end
  
  def convert_program
    Program.new(
      @score.program.segments.map do |seg|
        @mnoff_map[seg.first]...@mnoff_map[seg.last]
      end
    )
  end
  
  def convert_start_tempo
    Tempo::BPM.to_qnpm(@score.start_tempo, @score.start_meter.beat_duration)
  end
  
  def convert_tempo_changes
    tcs = {}
    bdurs = @score.beat_durations
    
    @score.tempo_changes.each do |moff,change|
      bdur = bdurs.select {|x,y| x <= moff}.max[1]
      tempo = change.value
      
      case change
      when Change::Immediate
        tcs[@mnoff_map[moff]] = Change::Immediate.new(Tempo::BPM.to_qnpm(tempo,bdur))
      when Change::Gradual
        start_moff, end_moff = moff, moff + change.duration
        start_noff, end_noff = @mnoff_map[start_moff], @mnoff_map[end_moff]
        
        initial_moff, final_moff = start_moff - change.elapsed, end_moff + change.remaining
        initial_noff, final_noff = @mnoff_map[initial_moff], @mnoff_map[final_moff]
        
        more_bdurs = bdurs.select {|x,y| x > start_moff && x < end_moff }
        cur_noff, cur_bdur = start_noff, bdur
        
        more_bdurs.each do |next_moff, next_bdur|
          next_noff = @mnoff_map[next_moff]
          elapsed = cur_noff - initial_noff
          impending = next_noff - cur_noff
          remaining = final_noff - next_noff
          tempo2 = Tempo::BPM.to_qnpm(tempo, cur_bdur)
          tcs[cur_noff] = Change::Gradual.new(tempo2, impending, elapsed, remaining)
          cur_noff, cur_bdur = next_noff, next_bdur
        end
        elapsed = cur_noff - initial_noff
        impending = end_noff - cur_noff
        remaining = final_noff - end_noff
        tempo2 = Tempo::BPM.to_qnpm(tempo, cur_bdur)
        tcs[cur_noff] = Change::Gradual.new(tempo2, impending, elapsed, remaining)
      end
    end
    
    return tcs
  end
end

end