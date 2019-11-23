module Musicality

class Key
  include Packable

  FLAT = :flat
  SHARP = :sharp
  NONE = :none
  ACCIDENTAL_TYPES = [FLAT, SHARP, NONE]

  MAJOR = :major
  MINOR = :minor
  TRIAD_TYPES = [MAJOR, MINOR]

  TONIC_PCS = {
    MAJOR => {
      FLAT => [PitchClasses::F, PitchClasses::Bb, PitchClasses::Eb,
        PitchClasses::Ab, PitchClasses::Db, PitchClasses::Gb],
      SHARP => [PitchClasses::G,PitchClasses::D,PitchClasses::A,
        PitchClasses::E,PitchClasses::B]
    },
    MINOR => {
      FLAT => [PitchClasses::D,PitchClasses::G,PitchClasses::C,
        PitchClasses::F,PitchClasses::Bb,PitchClasses::Eb],
      SHARP => [PitchClasses::E,PitchClasses::B,PitchClasses::Fs,
        PitchClasses::Cs,PitchClasses::Gs]
    }
  }

  ACCIDENTALS = {
    FLAT => [PitchClasses::Bb,PitchClasses::Eb,PitchClasses::Ab,PitchClasses::Db,
      PitchClasses::Gb,PitchClasses::Cb,PitchClasses::Fb],
    SHARP => [PitchClasses::Fs,PitchClasses::Cs,PitchClasses::Gs,
      PitchClasses::Ds,PitchClasses::As,PitchClasses::Es,PitchClasses::Bs]
  }

  attr_reader :tonic_pc, :triad_type, :accidentals, :accidental_type

  def initialize tonic_pc, triad_type: MAJOR
    raise ArgumentError, "Unknown triad type #{triad_type}" unless TRIAD_TYPES.include?(triad_type)
    @triad_type = triad_type
    @tonic_pc = PitchClass.from_i(tonic_pc)

    if (@triad_type == MAJOR && @tonic_pc == PitchClasses::C) ||
        (@triad_type == MINOR && @tonic_pc == PitchClasses::A)
      @accidentals = []
      @accidental_type = NONE
    else
      if TONIC_PCS[@triad_type][FLAT].include?(@tonic_pc)
        @accidental_type = FLAT
      elsif TONIC_PCS[@triad_type][SHARP].include?(@tonic_pc)
        @accidental_type = SHARP
      else
        raise ArgumentError, "unknown tonic PC #{@tonic_pc}"
      end
      i = TONIC_PCS[@triad_type][@accidental_type].index(@tonic_pc)
      @accidentals = ACCIDENTALS[@accidental_type][0..i]
    end
  end

  def self.major tonic_pc
    Key.new(tonic_pc, triad_type: MAJOR)
  end

  def self.minor tonic_pc
    Key.new(tonic_pc, triad_type: MINOR)
  end

  def major?; @triad_type == MAJOR; end
  def minor?; @triad_type == MINOR; end

  def flat?; @accidental_type == FLAT; end
  def sharp?; @accidental_type == SHARP; end

  def ==(other)
    return @tonic_pc == other.tonic_pc && @triad_type == other.triad_type
  end

  def clone
    Marshal.load(Marshal.dump(self))
  end

  def transpose interval
    Key.new(PitchClass.from_i(@tonic_pc+interval), @triad_type)
  end
end

end
