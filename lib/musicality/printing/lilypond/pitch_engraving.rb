module Musicality

class Pitch
  def to_lilypond sharpit = false
    output = PitchClass.to_lilypond(semitone, sharpit)

    if octave > 3
      output += "'"*(octave - 3)
    elsif octave < 3
      output += ","*(3 - octave)
    end

    return output
  end
end

end