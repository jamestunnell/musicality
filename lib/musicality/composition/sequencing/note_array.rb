module Musicality

class NoteArray
  include Sequenceable

  attr_reader :duration, :notes
  def initialize notes
    raise ArgumentError if notes.empty?

    @notes = notes.clone.freeze
    @notes_idx = 0
    @notes_count = notes.size

    @duration = @notes.inject(0) {|sum, note| sum + note.duration}
  end

  def next_note
    note = @notes[@notes_idx]

    @notes_idx += 1
    if @notes_idx >= @notes_count
      @notes_idx = 0
    end

    return note
  end

  def reset
    @notes_idx = 0
  end
end

end
