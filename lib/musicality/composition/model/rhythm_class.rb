module Musicality

# A rhythm pattern based on an array of "portions". These portions encode an
# array of fractions that sum to 1 (each portion would be numerator and the
# sum of all portions would be the denominator). These fractions can be applied
# to a total duration to form a rhythm (an array of durations).
# @note Rests are represented by neagtive portions.
class RhythmClass
  attr_reader :portions_sum, :portions
  def initialize portions
    if portions.find {|x| x.zero? }
      raise ArgumentError, "rhythm class contains portion(s) that are zero"
    end
    @portions = portions.clone.freeze
    @portions_sum = @portions.inject(0) {|sum,x| sum + x.abs}
  end

  # Use the rhythm class to generate a rhtyhm
  def to_rhythm(total_dur)
    Rhythm.new @portions.map {|x| Rational(x,@portions_sum) * total_dur }
  end
end

end

class Array
  def to_rhythm_class
    Musicality::RhythmClass.new(self)
  end
end
