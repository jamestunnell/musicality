module Musicality

class Score
  class Tempo < Score
    # See ScoreEngraver#make_lilypond for details on supported keyword args
    def to_lilypond selected_parts = @parts.keys
      ScoreEngraver.new(self).make_lilypond(selected_parts)
    end
  end
end

end