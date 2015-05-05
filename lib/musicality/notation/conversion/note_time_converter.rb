module Musicality

# Convert offsets in measured note time to just plain time. 
class NoteTimeConverter
  # @param [ValueComputer] tempo_computer Given an offset, returns tempo
  # value in quarter-notes-per-minute
  # @param [Numeric] sample_rate Rate at which tempo values are sampled
  # in the conversion (samples/sec).
  def initialize tempo_computer, bdur_computer, sample_rate
    @tempo_computer = tempo_computer
    @bdur_computer = bdur_computer
    @sample_period = Rational(1,sample_rate)
  end

  def notes_per_second_at offset
    Tempo::BPM.to_nps(@tempo_computer.at(offset), @bdur_computer.at(offset))
  end
  
  # Calculate the time elapsed between given start/end note offset. Using the
  # notes-per-second values over this interval, note duration for each sample is
  # known and accumulated as samples are taken. When accumulated note duration
  # passes the given desired duration (end_offset - start_offset), the number of
  # samples taken will indicated the corresponding time duration. Then there
  # is adjustment for last sample taken, which likely goes past the desired note
  # duration.
  #
  # @param [Numeric] start_offset the starting note offset.
  # @param [Numeric] end_offset the ending note offset.
  # @raise [ArgumentError] if end offset is less than starting offset.
  def time_elapsed start_offset, end_offset
    raise ArgumentError "note end is less than note begin" if end_offset < start_offset
    
    time_samples = 0
    offset = start_offset
    
    while offset < end_offset
      notes_per_sec = notes_per_second_at offset
      notes_per_sample = notes_per_sec * @sample_period
      
      if (offset + notes_per_sample) > end_offset
        #interpolate between offset and end_offset
        perc = (end_offset - offset) / notes_per_sample
        time_samples += perc
        offset = end_offset
      else
        time_samples += 1
        offset += notes_per_sample
      end
    end
    
    return time_samples * @sample_period
  end

  #map absolute note offsets to relative time offsets
  def note_time_map offsets
    time_counter = 0.0
    sorted_offsets = offsets.sort
    note_time_map = { sorted_offsets.first => time_counter }
    
    for i in 1...sorted_offsets.count do
      time_counter += time_elapsed(sorted_offsets[i-1], sorted_offsets[i])
      note_time_map[sorted_offsets[i]] = time_counter
    end
    
    return note_time_map
  end
end

end
