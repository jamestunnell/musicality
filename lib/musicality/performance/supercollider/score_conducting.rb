module Musicality

class Score
  class Timed < Score
    def to_osc base_fpath, **kwargs
      SuperCollider::Conductor.new(self).perform(base_fpath, **kwargs)
    end
  end

  class Tempo < Score
    def to_osc tempo_sample_rate, base_fpath, **kwargs
      to_timed(tempo_sample_rate).to_osc(base_fpath, **kwargs)
    end
  end
end

end