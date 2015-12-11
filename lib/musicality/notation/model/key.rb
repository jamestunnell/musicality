module Musicality

class Key
  include Packable
  
  FLAT = :flat
  SHARP = :sharp
  ACCIDENTAL_TYPES = [FLAT, SHARP]
  
  MAJOR = :major
  MINOR = :minor
  TRIAD_TYPES = [MAJOR, MINOR]
  
  TONICS = {
    MAJOR => {
      FLAT => [PitchClasses::F, PitchClasses::Bb, PitchClasses::Eb,
        PitchClasses::Ab, PitchClasses::Db, PitchClasses::Gb, PitchClasses::Cb],
      SHARP => [PitchClasses::G,PitchClasses::D,PitchClasses::A,
        PitchClasses::E,PitchClasses::B,PitchClasses::Fs,PitchClasses::Cs]
    },
    MINOR => {
      FLAT => [PitchClasses::D,PitchClasses::G,PitchClasses::C,
        PitchClasses::F,PitchClasses::Bb,PitchClasses::Eb,PitchClasses::Ab],
      SHARP => [PitchClasses::E,PitchClasses::B,PitchClasses::Fs,
        PitchClasses::Cs,PitchClasses::Gs,PitchClasses::Ds,PitchClasses::As]
    }
  }

  ACCIDENTALS = {
    FLAT => [PitchClasses::Bb,PitchClasses::Eb,PitchClasses::Ab,PitchClasses::Db,
      PitchClasses::Gb,PitchClasses::Cb,PitchClasses::Fb],
    SHARP => [PitchClasses::Fs,PitchClasses::Cs,PitchClasses::Gs,
      PitchClasses::Ds,PitchClasses::As,PitchClasses::Es,PitchClasses::Bs]
  }

  attr_reader :tonic_pc, :triad, :accidental_pref
  
  def initialize tonic_pc, triad: MAJOR, accidental_pref: FLAT
    self.tonic_pc = tonic_pc
    self.triad = triad
    self.accidental_pref = accidental_pref
  end
  
  def self.major_flat tonic_pc
    Key.new(tonic_pc, triad: MAJOR, accidental_pref: FLAT)
  end
  
  def self.major_sharp tonic_pc
    Key.new(tonic_pc, triad: MAJOR, accidental_pref: SHARP)
  end
  
  def self.minor_flat tonic_pc
    Key.new(tonic_pc, triad: MINOR, accidental_pref: FLAT)
  end
  
  def self.minor_sharp tonic_pc
    Key.new(tonic_pc, triad: MINOR, accidental_pref: SHARP)
  end
  
  def major?; @triad == MAJOR; end
  def minor?; @triad == MINOR; end
  
  def flat?; accidental_type == FLAT; end
  def sharp?; accidental_type == SHARP; end
  
  def accidental_free?
    (major? && @tonic_pc == PitchClasses::C) || (minor? && @tonic_pc == PitchClasses::A)
  end

  def triad= triad
    if triad != @triad
      unless TRIAD_TYPES.include? triad
        raise ArgumentError, "Triad type #{triad} is not supported"
      end
      @triad = triad
      reset_accidentals
    end
  end

  def accidental_pref= accidental_pref
    if accidental_pref != @accidental_pref
      unless ACCIDENTAL_TYPES.include? accidental_pref
        raise ArgumentError, "Accidental type #{accidental_pref} is not supported"
      end
      @accidental_pref = accidental_pref
      reset_accidentals
    end
  end

  def tonic_pc= tonic_pc
    if tonic_pc != @tonic_pc
      @tonic_pc = PitchClass.from_i(tonic_pc)
      reset_accidentals
    end
  end
  
  def ==(other)
    return @tonic_pc == other.tonic_pc && @triad == other.triad && 
      @accidental_pref == other.accidental_pref
  end

  def clone
    Marshal.load(Marshal.dump(self))
  end
  
  def accidentals
    unless @accidentals
      @accidentals = []
      unless accidental_free?
        acc_type = accidental_type
        idx = TONICS[@triad][acc_type].index(@tonic_pc)
        @accidentals = ACCIDENTALS[acc_type].take(idx+1)
      end
    end
    return @accidentals
  end
  
  def accidental_type
    if accidental_free? || TONICS[@triad][@accidental_pref].include?(@tonic_pc)
      @accidental_pref
    else
      (@accidental_pref == FLAT) ? SHARP : FLAT
    end
  end

  def transpose interval
    new_key = self.clone
    new_key.tonic_pc += interval
    return new_key
  end

  private

  def reset_accidentals; @accidentals = nil; end
end

end
