module Musicality

class Tempo
  def convert tgt_class, bdur = nil
    args = (is_a?(BPM) || tgt_class == BPM) ? [bdur] : []
    
    return case tgt_class.new(1)
    when self.class then self.clone
    when Tempo::QNPM then to_qnpm(*args)
    when Tempo::NPM then to_npm(*args)
    when Tempo::NPS then to_nps(*args)
    when Tempo::BPM then to_bpm(*args)
    else
      raise TypeError, "Unexpected target tempo class #{tgt_class}"
    end
  end
  
  class QNPM < Tempo
    def to_npm
      Tempo::NPM.new(Rational(@value,4))
    end
    
    def to_nps
      Tempo::NPS.new(Rational(@value,240))
    end
    
    def to_bpm beat_dur
      Tempo::BPM.new(Rational(@value,4*beat_dur))
    end
  end

  class NPM < Tempo
    def to_qnpm
      Tempo::QNPM.new(4*@value)
    end
    
    def to_nps
      Tempo::NPS.new(Rational(@value,60))
    end
    
    def to_bpm beat_dur
      Tempo::BPM.new(Rational(@value,beat_dur))
    end
  end
  
  class BPM < Tempo
    def to_qnpm beat_dur
      Tempo::QNPM.new(4*beat_dur*@value)
    end
    
    def to_nps beat_dur
      Tempo::NPS.new(Rational(@value*beat_dur,60))
    end
    
    def to_npm beat_dur
      Tempo::NPM.new(beat_dur*@value)
    end
  end
  
  class NPS < Tempo
    def to_qnpm
      Tempo::QNPM.new(Rational(240,@value))
    end
    
    def to_bpm beat_dur
      Tempo::BPM.new(Rational(60,@value*beat_dur))
    end
    
    def to_npm
      Tempo::NPM.new(Rational(60,@value))
    end
  end
end

end