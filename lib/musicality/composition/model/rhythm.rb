module Musicality

# A rhythm based on an array of durations.
# @note Rests are represented by negative durations.
class Rhythm
  attr_reader :durations, :durations_sum

  def initialize durations
    if durations.find {|x| x.zero? }
      raise ArgumentError, "rhythm contains duration(s) that are zero"
    end
    @durations = durations.clone.freeze
    @durations_sum = @durations.inject(0) {|sum,x| sum + x.abs}
  end

  def to_notes pitch
    @durations.map do |dur|
      if dur.negative?
        Note.new(-dur)
      else
        Note.new(dur, pitch)
      end
    end
  end
end

end

class Array
  def to_rhythm
    Musicality::Rhythm.new(self)
  end
end
