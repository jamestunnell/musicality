module Musicality

class PitchClass
  MOD = 12 # semitones per octave
  
  def self.from_i i
    i % MOD
  end
  
  def self.invert val
    (MOD - val.to_pc).to_pc
  end
end
  
class Pitch
  def to_pc
    PitchClass.from_i semitone
  end
end

end

class Integer
  def to_pc
    PitchClass.from_i self
  end
end

module Enumerable
  def to_pcs
    map {|value| value.to_pc }
  end
end
