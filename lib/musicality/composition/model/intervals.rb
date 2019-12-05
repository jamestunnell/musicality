module Musicality

class Intervals
  include Enumerable

  attr_reader :offsets

  # Intervals are semitone offsets, each one relative to a yet-to-be-determined
  # root pitch. They must be sorted and in the range [1,11]
  def initialize offsets
    if offsets.none?
      raise ArgumentError, "No offsets given"
    end

    # if offsets.any? {|x| x <= 0 }
    #   raise NonPositiveError, "One or more offsets (#{offsets}) is non-positive"
    # end

    # if offsets.any? {|x| x >= 12 }
    #   raise ArgumentError, "One or more offsets (#{intervals}) is >= 12"
    # end

    # if offsets.sort != intervals
    #   raise ArgumentError, "Scale intervals (#{intervals}) are not sorted"
    # end

    @offsets = offsets
  end

  def ==(other)
    self.offsets == other.offsets
  end

  def each
    return @offsets.each unless block_given?
    @offsets.each {|x| yield x }
  end

  # Produces offsets relative to previous interval, ending with an extra offset
  # that will result in a cumulative octave offset
  def interval_vector
    iv = [@offsets.first]
    if @offsets.size > 1
      iv += Array.new(@offsets.size-1) {|i| @offsets[i+1] - @offsets[i]}
    end
    iv += [12 - @offsets.last]

    return iv
  end

  def to_pc_seq start_pc
    AddingSequence.new(interval_vector(), start_pc)
  end

  def to_pitch_seq start_pitch
    AddingSequence.new(interval_vector(), start_pitch)
  end

  def to_scale root_pc
    Scale.new(root_pc, @offsets)
  end

  def rotate n = 1
    iv = interval_vector().rotate(n)
    seq = AddingSequence.new(iv[1...iv.size], iv[0])
    Intervals.new(seq.take(iv.size-1).to_a)
  end
end

end
