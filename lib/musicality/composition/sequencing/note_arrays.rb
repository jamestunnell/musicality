module Musicality

class NoteArrays
  include Sequenceable

  def initialize note_arrays
    raise ArgumentError if note_arrays.empty?

    @note_arrays = note_arrays
    @note_array_idx = 0
    @note_array_count = note_arrays.size
  end

  def next_notes
    notes = @note_arrays[@note_array_idx]

    @note_array_idx += 1
    if @note_array_idx >= @note_array_count
      @note_array_idx = 0
    end

    return notes
  end

  def reset
    @note_array_idx = 0
  end
end

end
