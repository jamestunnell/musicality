module Musicality

class MeasureScore
  # Convert to NoteScore object by first converting measure-based offsets to
  # note-based offsets, and eliminating the use of meters. Also, tempo is
  # to non-BPM tempo.
  def to_note_score tempo_class
    MeasureScoreConverter.new(self).convert_score(tempo_class)
  end
  
  def measure_note_map
    Conversion::measure_note_map(measure_offsets,measure_durations)
  end
  
  def measure_offsets
    moffs = Set.new([0.to_r])
    
    @tempo_changes.each do |moff,change|
      moffs.add(moff)
      if change.duration > 0
        moffs.add(moff + change.duration)
      end
    end
    
    @meter_changes.keys.each {|moff| moffs.add(moff) }
    
    @parts.values.each do |part|
      part.dynamic_changes.each do |moff,change|
        moffs.add(moff)
        if change.duration > 0
          moffs.add(moff + change.duration)
        end
      end
    end
    
    @program.segments.each do |seg|
      moffs.add(seg.first)
      moffs.add(seg.last)
    end
    
    return moffs.sort
  end

  def beat_durations
    bdurs = @meter_changes.map do |offset,change|
      [ offset, change.value.beat_duration ]
    end.sort
    
    if bdurs.empty? || bdurs[0][0] != 0
      bdurs.unshift([0,@start_meter.beat_duration])
    end
  
    return bdurs
  end
  
  def measure_durations
    mdurs = @meter_changes.map do |offset,change|
      [ offset, change.value.measure_duration ]
    end.sort
    
    if mdurs.empty? || mdurs[0][0] != 0
      mdurs.unshift([0,@start_meter.measure_duration])
    end
  
    return Hash[ mdurs ]
  end  
end
  
end