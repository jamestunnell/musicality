module Musicality

class NoteSequence
  Element = Struct.new(:duration, :pitch, :attack)

  def self.adjust_duration duration, separation
    function = case separation
    when Separation::TENUTO
      DurationFunctions::TENUTO_DURATION
    when Separation::PORTATO
      DurationFunctions::PORTATO_DURATION
    when Separation::STACCATO
      DurationFunctions::STACCATO_DURATION
    when Separation::STACCATISSIMO
      DurationFunctions::STACCATISSIMO_DURATION
    else
      DurationFunctions::NORMAL_DURATION
    end

    function.at(duration)
  end

  attr_accessor :offset, :separation, :elements
  def initialize offset, separation, elements = []
    @offset = offset
    @separation = separation
    @elements = elements
  end

  alias start offset
  
  def offsets
    raise "contains no elements" if elements.empty?
    
    off = @offset
    elements.map do |e|
      x = off
      off += e.duration
      x
    end
  end
  
  def stop
    offsets.last + NoteSequence.adjust_duration(elements.last.duration, separation)
  end

  def duration
    stop - offset
  end

  def full_duration
    @elements.map {|el| el.duration }.inject(0,:+)
  end

  def first_pitch
    elements.first.pitch
  end

  def last_pitch
    elements.last.pitch
  end

  def last_attack
    elements.last.attack
  end
end

end
