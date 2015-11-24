module Musicality

class NoteSequence
  Element = Struct.new(:duration, :pitch, :attack)

  def self.adjust_duration duration, separation
    x = duration
    y = Math.log2(x)

    case separation
    when Separation::TENUTO
      x
    when Separation::PORTATO
      x / (1 + 2**(y-1))
    when Separation::STACCATO
      x / (1 + 2**(y))
    when Separation::STACCATISSIMO
      x / (1 + 2**(y+1))
    else
      x - (1/16.0)*(1/(1+2**(-y)))
    end
  end

  attr_accessor :offset, :separation, :elements
  def initialize offset, separation, elements = []
    @offset = offset
    @separation = separation
    @elements = elements
  end

  alias start offset
  
  def offsets
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
    offsets.last + elements.last.duration
  end

  def first_pitch
    elements.first.pitch
  end

  def last_pitch
    elements.last.pitch
  end

  def first_attack
    elements.first.attack
  end

  def last_attack
    elements.last.attack
  end

  # attr_reader :start, :stop, :pitches, :attack
  # def initialize start, stop, pitches, attack
    # if start >= stop
      # raise ArgumentError, "start #{start} is not less than stop #{stop}"
    # end
    
    # if pitches.empty?
      # raise ArgumentError, "no pitches given (at least one pitch is required at start offset)"
    # end
    
    # unless pitches.has_key?(start)
      # raise ArgumentError, "no start pitch given"
    # end
    
    # pitches.keys.each do |offset|
      # unless offset.between?(start,stop)
        # raise ArgumentError, "pitch offset #{offset} is not between start #{start} and stop #{stop}"
      # end
    # end
    
    # @start, @stop, @pitches, @attack = start, stop, pitches, attack
  # end
    
  # def self.from_elements offset, elements, attack, final_articulation
    # pitches = {}
    # start = offset
    
    # if elements.empty?
      # raise ArgumentError, "no elements given"
    # end
      
    # last = elements.last
    # elements.each do |el|
      # pitches[offset] = el.pitch
      
      # unless el.equal?(last)
        # offset += el.duration
      # end
    # end
    # stop = offset + NoteSequence.adjust_duration(last.duration, final_articulation)
    
    # new(start, stop, pitches, attack)
  # end

  # def duration; @stop - @start; end
end

end
