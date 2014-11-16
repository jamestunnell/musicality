module Musicality

class MeasureScore
  # Convert to NoteScore object by first converting measure-based offsets to
  # note-based offsets, and eliminating the use of meters. Also, tempo is
  # to non-BPM tempo.
  def to_note_score tempo_class = Tempo::QNPM
    unless valid?
      raise NotValidError, "Current MeasureScore is invalid, so it can not be \
                            converted to a NoteScore. Validation errors: #{self.errors}"
    end
    
    unless NoteScore.valid_tempo_types.include? tempo_class
      raise TypeError, "The desired tempo class #{tempo_class} is not valid for a NoteScore."
    end
    
    mnoff_map = self.measure_note_map
    parts = convert_parts(mnoff_map)
    prog = convert_program(mnoff_map)
    tcs = convert_tempo_changes(tempo_class, mnoff_map)
    start_tempo = @start_tempo.convert(tempo_class,@start_meter.beat_duration)
    
    NoteScore.new(start_tempo, parts: parts, program: prog, tempo_changes: tcs)
  end
  
  def measure_note_map
    Conversion::measure_note_map(measure_offsets,measure_durations)
  end
  
  def convert_parts mnoff_map = self.measure_note_map
    Hash[ @parts.map do |name,part|
      new_dcs = Hash[ part.dynamic_changes.map do |moff,change|
        noff = mnoff_map[moff]
        noff2 = mnoff_map[moff + change.duration]
        [noff, change.resize(noff2-noff)]
      end ]
      new_notes = part.notes.map {|n| n.clone }
      [name, Part.new(part.start_dynamic,
        notes: new_notes, dynamic_changes: new_dcs)]
    end ]
  end
  
  def convert_program mnoff_map = self.measure_note_map
    Program.new(
      @program.segments.map do |seg|
        mnoff_map[seg.first]...mnoff_map[seg.last]
      end
    )
  end
  
  def convert_tempo_changes tempo_class, mnoff_map = self.measure_note_map
    tcs = {}
    bdurs = beat_durations
    
    @tempo_changes.each do |moff,change|
      bdur = bdurs.select {|x,y| x <= moff}.max[1]
      tempo = change.value
      
      case change
      when Change::Immediate
        tcs[mnoff_map[moff]] = Change::Immediate.new(tempo.convert(tempo_class,bdur))
      when Change::Gradual
        start_moff, end_moff = moff, moff + change.duration
        start_noff, end_noff = mnoff_map[start_moff], mnoff_map[end_moff]
        cur_noff, cur_bdur = start_noff, bdur

        more_bdurs = bdurs.select {|x,y| x > moff && x < end_moff }
        if more_bdurs.any?
          more_bdurs.each do |next_moff, next_bdur|
            next_noff = mnoff_map[next_moff]
            elapsed = cur_noff - start_noff
            impending = next_noff - cur_noff
            remaining = end_noff - next_noff
            tempo2 = tempo.convert(tempo_class, cur_bdur)
            tcs[cur_noff] = Change::Partial.new(tempo2, elapsed, impending, remaining)
            cur_noff, cur_bdur = next_noff, next_bdur
          end
          elapsed = cur_noff - start_noff
          impending = end_noff - cur_noff
          remaining = 0
          tempo2 = tempo.convert(tempo_class, cur_bdur)
          tcs[cur_noff] = Change::Partial.new(tempo2,elapsed, impending, remaining)
        else
          tcs[start_noff] = Change::Gradual.new(
            tempo.convert(tempo_class, cur_bdur), end_noff - start_noff)
        end
      when Change::Partial
        raise NotImplementedError, "No support yet for converting partial tempo changes."
      end
    end
    
    return tcs
  end
  
  def beat_duration_at moff
    beat_durations.select {|k,v| k <= moff }.max[1]
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