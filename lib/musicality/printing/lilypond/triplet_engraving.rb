module Musicality

class Triplet
  def to_lilypond
    "\\tuplet 3/2 { " + @notes.map {|n| n.to_lilypond }.join(" ") + " }"
  end
end

end