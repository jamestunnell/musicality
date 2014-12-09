module Musicality

module ScaleClasses
  CHROMATIC = ScaleClass.new([1,1,1,1,1,1,1,1,1,1,1,1])
  
  module Pentatonic
    MINOR = ScaleClass.new([3,2,2,3,2])
    MAJOR = MINOR.rotate(1)
    EGYPTIAN = MINOR.rotate(2)
    MINOR_BLUES = MINOR.rotate(3)
    MAJOR_BLUES = MINOR.rotate(4)

    MODES = {
      1 => MINOR,
      2 => MAJOR,
      3 => EGYPTIAN,
      4 => MINOR_BLUES,
      5 => MAJOR_BLUES
    }
  end
  
  module Hexatonic
    WHOLE_TONE = ScaleClass.new([2,2,2,2,2,2])
    AUGMENTED = ScaleClass.new([3,1,3,1,3,1])
    MYSTIC = PROMETHEAN = ScaleClass.new([2,2,2,3,1,2])
    BLUES = ScaleClass.new([3,2,1,1,3,2])
    TRITONE = PETRUSHKA = ScaleClass.new([1,3,2,1,3,2])
  end

  module Heptatonic
    # This is where the standard Major scale and its modes are found, among others.
    module Prima
      IONIAN = MAJOR = ScaleClass.new([2,2,1,2,2,2,1])
      DORIAN = IONIAN.rotate(1)
      PHRYGIAN = IONIAN.rotate(2)
      LYDIAN = IONIAN.rotate(3)
      MIXOLYDIAN = IONIAN.rotate(4)
      AEOLIAN = MINOR = IONIAN.rotate(5)
      LOCRIAN = IONIAN.rotate(6)
      
      MODES = {
        1 => IONIAN,
        2 => DORIAN,
        3 => PHRYGIAN,
        4 => LYDIAN,
        5 => MIXOLYDIAN,
        6 => AEOLIAN,
        7 => LOCRIAN
      }
    end

    module Secunda
      JAZZ_MINOR = MELODIC_MINOR = ScaleClass.new([2,1,2,2,2,2,1])
      PHRYGIAN_RAISED_SIXTH = MELODIC_MINOR.rotate(1)
      LYDIAN_RAISED_FIFTH = MELODIC_MINOR.rotate(2)
      ACOUSTIC = LYDIAN_DOMINANT = MELODIC_MINOR.rotate(3)
      MAJOR_MINOR = MELODIC_MINOR.rotate(4)
      HALF_DIMINISHED = MELODIC_MINOR.rotate(5)
      ALTERED = MELODIC_MINOR.rotate(6)

      MODES = {
        1 => MELODIC_MINOR,
        2 => PHRYGIAN_RAISED_SIXTH,
        3 => LYDIAN_RAISED_FIFTH,
        4 => ACOUSTIC,
        5 => MAJOR_MINOR,
        6 => HALF_DIMINISHED,
        7 => ALTERED
      }
    end

    module Other
      GYPSY = ScaleClass.new([1,3,1,2,1,3,1])
      HUNGARIAN = ScaleClass.new([2,1,3,1,1,3,1])
      PHRYGIAN_MAJOR = ScaleClass.new([1,3,1,2,1,2,2])
      SCALA_ENIGMATICA = ScaleClass.new([1,3,2,2,2,1,1])
    end
  end

  module Octatonic
    WHOLE_HALF = ScaleClass.new([2,1,2,1,2,1,2,1])
    HALF_WHOLE = WHOLE_HALF.rotate(1)

    MODES = {
      1 => WHOLE_HALF,
      2 => HALF_WHOLE
    }
  end
end

end
