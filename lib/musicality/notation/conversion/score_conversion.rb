module Musicality

class Score
  class Unmeasured < TempoBased
    # Convert to timed score by converting measure-based offsets and note-based
    # durations to time-based. This eliminates the use of tempos.
    def to_timed tempo_sample_rate
      ScoreConverter::Unmeasured.new(self, tempo_sample_rate).convert_score
    end      
  end
  
  class Measured < TempoBased
    # Convert to timed score by converting measure-based offsets and note-based
    # durations to time-based. This eliminates the use of meters and tempos.
    def to_timed tempo_sample_rate
      ScoreConverter::Measured.new(self, tempo_sample_rate).convert_score
    end
    
    def measure_note_map
      Conversion::measure_note_map(measure_offsets,measure_durations)
    end

    def measure_offsets
      moffs = Set.new([0.to_r])
      @tempo_changes.each {|moff,change| moffs += change.offsets(moff) }
      @meter_changes.keys.each {|moff| moffs.add(moff) }
      @parts.values.each do |part|
        part.dynamic_changes.each {|moff,change| moffs += change.offsets(moff) }
      end
      moffs += @program.segments.map {|seg| [seg.first, seg.last] }.flatten
      return moffs.sort
    end
  
    def beat_durations
      bdurs = @meter_changes.map do |offset,change|
        [ offset, change.end_value.beat_duration ]
      end.sort
      
      if bdurs.empty? || bdurs[0][0] != 0
        bdurs.unshift([0.to_r,@start_meter.beat_duration])
      end
    
      return Hash[ bdurs ]
    end
    
    def measure_durations
      mdurs = @meter_changes.map do |offset,change|
        [ offset, change.end_value.measure_duration ]
      end.sort
      
      if mdurs.empty? || mdurs[0][0] != 0
        mdurs.unshift([0.to_r,@start_meter.measure_duration])
      end
    
      return Hash[ mdurs ]
    end  
  end
end

end