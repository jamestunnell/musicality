module Musicality

class Tempo
  class QNPM
    def self.to_bpm qnpm, beat_dur
      Rational(qnpm,4*beat_dur)
    end
    
    def self.to_nps qnpm
      Rational(qnpm,240)
    end
  end
  
  class BPM
    def self.to_qnpm bpm, beat_dur
      4*beat_dur*bpm
    end
    
    def self.to_nps bpm, beat_dur
      Rational(bpm*beat_dur,60)
    end
  end
end
  
end