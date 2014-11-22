module Musicality

class Score
  class Unmeasured < TempoBased
    # Convert to unmeasured score by converting measure-based offsets to
    # note-based offsets, and eliminating the use of meters. Also, tempo is
    # coverted from beats-per-minute to quarter-notes per minute.
    def to_timed tempo_sample_rate
      UnmeasuredScoreConverter.new(self,tempo_sample_rate).convert_score
    end
    
    def note_time_map tempo_sample_rate
      tempo_computer = ValueComputer.new(@start_tempo, @tempo_changes)
      ntc = NoteTimeConverter.new(tempo_computer, tempo_sample_rate)
      ntc.note_time_map(note_offsets)
    end
        
    def note_offsets
      noffs = Set.new([0.to_r])
      
      @tempo_changes.each do |noff,change|
        noffs += change.offsets(noff)
      end
      
      @parts.values.each do |part|
        noff = 0.to_r
        part.notes.each do |note|
          noff += note.duration
          noffs.add(noff)
        end
        
        part.dynamic_changes.each do |noff,change|
          noffs += change.offsets(noff)
        end
      end
      
      @program.segments.each do |seg|
        noffs.add(seg.first)
        noffs.add(seg.last)
      end
      
      return noffs.sort
    end
  end
end

end