module Musicality

class Meter
  def to_lilypond
    num = beats_per_measure * beat_duration.numerator
    den = beat_duration.denominator
    "#{num}/#{den}"
  end
end

end