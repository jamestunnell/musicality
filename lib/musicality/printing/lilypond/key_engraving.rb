module Musicality

class Key
  def to_lilypond
    "\\key #{PitchClass.to_lilypond(@tonic_pc, sharp?)} \\#{@triad}"
  end
end

end
