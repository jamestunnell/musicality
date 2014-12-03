module Musicality

class NoteGenerator
  def self.make_note dur, pitch_group
    if dur > 0
      Musicality::Note.new(dur,pitch_group)
    else
      Musicality::Note.new(-dur)
    end
  end
  
  # Whichever is longer, rhythm or pitch_groups, is iterated over once while
  # the smaller will cycle as necessary.
  def self.make_notes rhythm, pitch_groups
    m,n = rhythm.size, pitch_groups.size
    raise EmptyError, "rhythm is empty" if m == 0
    raise EmptyError, "pitch_groups is empty" if n == 0
    
    if m > n
      Array.new(m) do |i|
        make_note(rhythm[i],pitch_groups[i % n])
      end
    else
      Array.new(n) do |i|
        make_note(rhythm[i % m],pitch_groups[i])
      end
    end
  end
end

end
