module Musicality

SlurredElement = Struct.new(:duration, :pitch, :accented) do
  def slurred?; true; end
  def articulation; Articulations::NORMAL; end
  def accented?; accented; end
end

LegatoElement = Struct.new(:duration, :pitch, :accented) do
  def slurred?; false; end
  def articulation; Articulations::NORMAL; end
  def accented?; accented; end
end

FinalElement = Struct.new(:duration, :pitch, :accented, :articulation) do
  def slurred?; false; end
  def accented?; accented; end
end

class NoteSequence
  def self.adjust_duration duration, articulation
    x = duration
    y = Math.log2(x)

    case articulation
    when Articulations::TENUTO
      x
    when Articulations::PORTATO
      x / (1 + 2**(y-1))
    when Articulations::STACCATO
      x / (1 + 2**(y))
    when Articulations::STACCATISSIMO
      x / (1 + 2**(y+1))
    else
      x - (1/16.0)*(1/(1+2**(-y)))
    end
  end

  attr_reader :start, :stop, :pitches, :attacks
  def initialize start, stop, pitches, attacks
    if start >= stop
      raise ArgumentError, "start #{start} is not less than stop #{stop}"
    end
    
    if pitches.empty?
      raise ArgumentError, "no pitches given (at least one pitch is required at start offset)"
    end
    
    unless pitches.has_key?(start)
      raise ArgumentError, "no start pitch given"
    end
    
    pitches.keys.each do |offset|
      unless offset.between?(start,stop)
        raise ArgumentError, "pitch offset #{offset} is not between start #{start} and stop #{stop}"
      end
    end
    
    if attacks.empty?
      raise ArgumentError, "no attacks given (at least one is required at start offset)"
    end
    
    unless attacks.has_key?(start)
      raise ArgumentError, "no start attack given"
    end
    
    attacks.keys.each do |offset|
      unless offset.between?(start,stop)
        raise ArgumentError, "attack offset #{offset} is not between start #{start} and stop #{stop}"
      end
    end
    
    @start, @stop = start, stop
    @pitches, @attacks = pitches, attacks
  end
    
  def self.from_elements offset, elements
    pitches = {}
    attacks = {}
    start = offset
    
    if elements.empty?
      raise ArgumentError, "no elements given"
    end
      
    last = elements.last
    skip_attack = false
    elements.each do |el|
      if skip_attack
        unless pitches.max[1] == el.pitch
          pitches[offset] = el.pitch
        end
      else
        pitches[offset] = el.pitch
        attacks[offset] = el.accented ? ACCENTED : UNACCENTED        
      end      
      skip_attack = el.slurred?
      
      unless el.equal?(last)
        offset += el.duration
      end
    end
    stop = offset + NoteSequence.adjust_duration(last.duration, last.articulation)
    
    new(start, stop, pitches, attacks)
  end

  def duration; @stop - @start; end
end

end
