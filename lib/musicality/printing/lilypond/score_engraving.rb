module Musicality

class Score
  class TempoBased < Score
    # See ScoreEngraver#make_lilypond for details on supported keyword args
    def to_lilypond **kwargs
      ScoreEngraver.new(self).make_lilypond(**kwargs)
    end
  end
end

end