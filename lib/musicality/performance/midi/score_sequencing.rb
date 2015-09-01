module Musicality

class Score
  class Timed < Score
    def to_midi_seq **kwargs
      ScoreSequencer.new(self).make_midi_seq(**kwargs)
    end
  end

  class Tempo < Score
    def to_midi_seq tempo_sample_rate, **kwargs
      to_timed(tempo_sample_rate).to_midi_seq(**kwargs)
    end
  end
end

end