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
        noff = @mnoff_map[moff]
        noff2 = @mnoff_map[moff + change.duration]
        [noff, change.resize(noff2-noff)]
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
        cur_noff, cur_bdur = start_noff, bdur

        more_bdurs = bdurs.select {|x,y| x > moff && x < end_moff }
        if more_bdurs.any?
          more_bdurs.each do |next_moff, next_bdur|
            next_noff = @mnoff_map[next_moff]
            elapsed = cur_noff - start_noff
            impending = next_noff - cur_noff
            remaining = end_noff - next_noff
            tempo2 = Tempo::BPM.to_qnpm(tempo, cur_bdur)
            tcs[cur_noff] = Change::Partial.new(tempo2, elapsed, impending, remaining)
            cur_noff, cur_bdur = next_noff, next_bdur
          end
          elapsed = cur_noff - start_noff
          impending = end_noff - cur_noff
          remaining = 0
          tempo2 = Tempo::BPM.to_qnpm(tempo, cur_bdur)
          tcs[cur_noff] = Change::Partial.new(tempo2,elapsed, impending, remaining)
        else
          tcs[start_noff] = Change::Gradual.new(
            Tempo::BPM.to_qnpm(tempo, cur_bdur), end_noff - start_noff)
        end
      when Change::Partial
        raise NotImplementedError, "No support yet for converting partial tempo changes."
      end
    end
    
    return tcs
  end
end

end