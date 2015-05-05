module Musicality

class Triplet
  attr_reader :duration

  def initialize note1, note2, note3
    @notes = [ note1, note2, note3 ]
    durs = @notes.map {|note| note.duration }.uniq
    raise DurationMismatchError, "Triplet notes do not have same duration" unless durs.one?
    @base_dur = durs.first
    @duration = @base_dur * 2
  end

  def first_note; @notes[0]; end
  def second_note; @notes[1]; end
  def third_note; @notes[2]; end

  def == other
    first_note == other.first_note && 
    second_note == other.second_note && 
    third_note == other.third_note
  end

  def clone
    notes = @notes.map {|n| n.clone }
    Triplet.new(*notes)
  end

  def transpose diff
    self.clone.transpose! diff
  end

  def transpose! diff
    @notes.each do |note|
      note.transpose! diff
    end
    return self
  end

  def duration= duration
    @base_dur = duration / 2
    @duration = duration
    @notes.each do |note|
      note.duration = @base_dur
    end
  end

  def resize duration
    new_triplet = self.clone
    new_triplet.duration = duration
    return new_triplet
  end

  def to_s
    @notes.join(TRIPLET_CONNECTOR)
  end

  # Produce an array of three notes whose duration has been altered 
  # to reflect the triplet proportion of 2/3
  RATIO = Rational(2,3)
  def expand
    new_dur = @base_dur*RATIO
    @notes.map {|n| n.resize(new_dur) }
  end

  def pitches
    @notes.map {|n| n.pitches }.flatten.uniq.sort
  end
end

end