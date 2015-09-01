module Musicality

# Abstraction of a musical pitch. Contains values for octave and semitone.
#
# Octaves represent the largest means of differing two pitches. Each
# octave added will double the ratio. At zero octaves, the ratio is
# 1.0. At one octave, the ratio will be 2.0. Each semitone is an increment
# of less-than-power-of-two.
#
# Semitones are the primary steps between octaves. The number of
# semitones per octave is 12.

# @author James Tunnell
#
# @!attribute [r] octave
#   @return [Fixnum] The pitch octave.
# @!attribute [r] semitone
#   @return [Fixnum] The pitch semitone.
#
class Pitch
  include Comparable
  attr_reader :octave, :semitone, :cent, :total_cents

  #The default number of semitones per octave is 12, corresponding to
  # the twelve-tone equal temperment tuning system.
  SEMITONES_PER_OCTAVE = PitchClass::MOD
  CENTS_PER_SEMITONE = 100
  CENTS_PER_OCTAVE = SEMITONES_PER_OCTAVE * CENTS_PER_SEMITONE

  # The base ferquency is C0
  BASE_FREQ = 16.351597831287414

  def initialize octave:0, semitone:0, cent: 0
    raise NonIntegerError, "octave #{octave} is not an integer" unless octave.is_a?(Integer)
    raise NonIntegerError, "semitone #{semitone} is not an integer" unless semitone.is_a?(Integer)
    raise NonIntegerError, "cent #{cent} is not an integer" unless cent.is_a?(Integer)
    
    @octave = octave
    @semitone = semitone
    @cent = cent
    @total_cents = (@octave*SEMITONES_PER_OCTAVE + @semitone)*CENTS_PER_SEMITONE + @cent
    balance!
  end

  # Return the pitch's frequency, which is determined by multiplying the base
  # frequency and the pitch ratio. Base frequency defaults to DEFAULT_BASE_FREQ,
  # but can be set during initialization to something else by specifying the
  # :base_freq key.
  def freq
    return self.ratio() * BASE_FREQ
  end

  # Calculate the pitch ratio. Raises 2 to the power of the total cent
  # count divided by cents-per-octave.
  # @return [Float] ratio
  def ratio
    2.0**(@total_cents.to_f / CENTS_PER_OCTAVE)
  end

  # Override default hash method.
  def hash
    return @total_cents
  end

  # Compare pitch equality using total semitone
  def ==(other)
    return (self.class == other.class &&
      @total_cents == other.total_cents)
  end

  def eql?(other)
    self == other
  end

  # Compare pitches. A higher ratio or total semitone is considered larger.
  # @param [Pitch] other The pitch object to compare.
  def <=> (other)
    @total_cents <=> other.total_cents
  end

  # rounds to the nearest semitone
  def round
    if @cent == 0
      self.clone
    else
      Pitch.new(semitone: (@total_cents / CENTS_PER_SEMITONE.to_f).round)
    end
  end

  # diff in (rounded) semitones
  def diff other
    Rational(@total_cents - other.total_cents, CENTS_PER_SEMITONE)
  end

  def transpose semitones
    Pitch.new(cent: (@total_cents + semitones * CENTS_PER_SEMITONE).round)
  end
  
  def + semitones
    transpose(semitones)
  end

  def - semitones
    transpose(-semitones)
  end
  
  def total_semitones
    Rational(@total_cents, CENTS_PER_SEMITONE)
  end
  
  def self.from_semitones semitones
    Pitch.new(cent: (semitones * CENTS_PER_SEMITONE).round)
  end
  
  def clone
    Pitch.new(cent: @total_cents)
  end

  def natural?
    [0,2,4,5,7,9,11].include?(semitone)
  end

  def self.pc_str semitone, sharpit
    case semitone
    when 0 then "C"
    when 1 then sharpit  ? "C#" : "Db"
    when 2 then "D"
    when 3 then sharpit  ? "D#" : "Eb"
    when 4 then "E"
    when 5 then "F"
    when 6 then sharpit  ? "F#" : "Gb"
    when 7 then "G"
    when 8 then sharpit  ? "G#" : "Ab"
    when 9 then "A"
    when 10 then sharpit  ? "A#" : "Bb"
    when 11 then "B"
    end
  end

  def to_s(sharpit = false)
    letter = Pitch.pc_str(semitone, sharpit)
    if @cent == 0
      return letter + octave.to_s
    elsif @cent > 0
      return letter + octave.to_s + "+" + @cent.to_s
    else
      return letter + octave.to_s + @cent.to_s
    end
  end

  def self.from_ratio ratio
    raise NonPositiveError, "ratio #{ratio} is not > 0" unless ratio > 0
    x = Math.log2 ratio
    new(cent: (x * CENTS_PER_OCTAVE).round)
  end

  def self.from_freq freq
    from_ratio(freq / BASE_FREQ)
  end

  private

  # Balance out the octave and semitone count.
  def balance!
    centsTotal = @total_cents
    
    @octave = centsTotal / CENTS_PER_OCTAVE
    centsTotal -= @octave * CENTS_PER_OCTAVE
    
    @semitone = centsTotal / CENTS_PER_SEMITONE
    centsTotal -= @semitone * CENTS_PER_SEMITONE
    
    @cent = centsTotal
    return self
  end
end

end
