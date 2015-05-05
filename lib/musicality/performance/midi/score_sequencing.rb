module Musicality

class Score
  class Timed < Score
    def to_midi_seq instr_map = {}
      ScoreSequencer.new(self).make_midi_seq(instr_map)
    end
  end

  class Tempo < Score
    def to_midi_seq tempo_sample_rate, instr_map = {}
      to_timed(tempo_sample_rate).to_midi_seq(instr_map)
    end
  end
end

end