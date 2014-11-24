module Musicality

module Conversion
  # Convert offsets from measure-based to note-based.
  # @param [Array] measure_offsets Measure offsets to be converted
  # @param [Hash] measure_durations Map measure durations to measure offsets where the duration takes effect.
  # @raise [NonZeroError] if first measure duration is not mapped to offset 0
  def self.measure_note_map measure_offsets, measure_durations
    mnoff_map = {}
    moffs = measure_offsets.uniq.sort
    mdurs = measure_durations.sort
    cur_noff = 0.to_r
    j = 0 # next measure offset to be converted
    
    if mdurs[0][0] != 0
      raise NonZeroError, "measure offset of 1st measure duration must be 0, not #{mdurs[0][0]}"
    end
    
    (0...mdurs.size).each do |i|
      cur_moff, cur_mdur = mdurs[i]
      if i < (mdurs.size - 1)
        next_moff = mdurs[i+1][0]        
      else
        next_moff = Float::INFINITY
      end
      
      while(j < moffs.size && moffs[j] <= next_moff) do
        moff = moffs[j]
        mnoff_map[moff] = cur_noff + (moff - cur_moff)*cur_mdur
        j += 1
      end
      
      cur_noff += (next_moff - cur_moff) * cur_mdur
    end
    
    return mnoff_map
  end
end

end