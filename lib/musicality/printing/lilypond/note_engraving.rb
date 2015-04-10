module Musicality

class Note
  def to_lilypond sharpit = false
    dur_strs = []
    d = duration
    
    if d > 1
      dur_strs += ["1"]*d.to_i
      d -= d.to_i
    end

    if d > 0
      n = Math.log2(d)
      if n < -7
        raise UnsupportedDurationError, "Note duration #{d} is too short for Lilypond"
      end

      if n.to_i == n # duration is exact power of two
        dur_strs.push (2**(-n)).to_i.to_s
      else # duration may be dotted
        undotted_duration = d/1.5
        n = Math.log2(undotted_duration)

        if n.to_i == n # duration (undotted) is exact power of two
          if n < -7
            raise UnsupportedDurationError, "Undotted note duration #{undotted_duration} is too short for Lilypond"
          end

          dur_strs.push (2**(-n)).to_i.to_s + "."
        else
          raise UnsupportedDurationError, "Leftover note duration #{d}is not power-of-two, and is not dotted power-of-two"
        end
      end
    end
    
    if pitches.any?
      if pitches.size == 1
        p_str = pitches.first.to_lilypond
      else
        p_str = "<" + pitches.map {|p| p.to_lilypond}.join(" ") + ">"
      end
      join_str = "~ "
    else
      p_str = "r"
      join_str = " "
    end

    return dur_strs.map {|dur_str| p_str + dur_str }.join(join_str)
  end
end

end