module Musicality

class Score
  class Tempo < Score
    # Convert to timed score by converting note-based offsets and durations 
    # to time-based. This eliminates the use of meters and tempos.
    def to_timed tempo_sample_rate
      ScoreConverter.new(self, tempo_sample_rate).convert_score
    end
      
    def beat_durations
      bdurs = @meter_changes.map do |offset,change_or_meter|
        if change_or_meter.is_a? Meter
          [ offset, change_or_meter.beat_duration ]
        else
          [ offset, change_or_meter.end_value.beat_duration ]
        end
      end.sort
      
      if bdurs.empty? || bdurs[0][0] != 0
        bdurs.unshift([0.to_r,@start_meter.beat_duration])
      end
    
      return Hash[ bdurs ]
    end
  end
end

end