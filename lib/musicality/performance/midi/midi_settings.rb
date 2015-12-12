module Musicality

class MidiSettings
  include Packable

  attr_reader :program

  def initialize program
    @program = program
  end

  ACOUSTIC_GRAND_PIANO = MidiSettings.new(1)
  BRIGHT_ACOUSTIC_PIANO = MidiSettings.new(2)
  ELECTRIC_GRAND_PIANO = MidiSettings.new(3)
  HONKY_TONK_PIANO = MidiSettings.new(4)
  ELECTRIC_PIANO_1 = MidiSettings.new(5)
  ELECTRIC_PIANO_2 = MidiSettings.new(6)
  HARPSICHORD = MidiSettings.new(7)
  CLAVINET = MidiSettings.new(8)
  CELESTA = MidiSettings.new(9)

  GLOCKENSPIEL = MidiSettings.new(10)
  MUSIC_BOX = MidiSettings.new(11)
  VIBRAPHONE = MidiSettings.new(12)
  MARIMBA = MidiSettings.new(13)
  XYLOPHONE = MidiSettings.new(14)
  TUBULAR_BELLS = MidiSettings.new(15)
  DULCIMER = MidiSettings.new(16)

  DRAWBAR_ORGAN = MidiSettings.new(17)
  PERCUSSIVE_ORGAN = MidiSettings.new(18)
  ROCK_ORGAN = MidiSettings.new(19)
  CHURCH_ORGAN = MidiSettings.new(20)
  REED_ORGAN = MidiSettings.new(21)
  ACCORDIAN = MidiSettings.new(22)
  HARMONICA = MidiSettings.new(23)
  TANGO_ACCORDIAN = MidiSettings.new(24)

  ACOUSTIC_GUITAR_NYLON = MidiSettings.new(25)
  ACOUSTIC_GUITAR_STEEL = MidiSettings.new(26)
  ELECTRIC_GUITAR_JAZZ = MidiSettings.new(27)
  ELECTRIC_GUITAR_CLEAN = MidiSettings.new(28)
  ELECTRIC_GUITAR_MUTED = MidiSettings.new(29)
  OVERDRIVEN_GUITAR = MidiSettings.new(30)
  DISTORTION_GUITAR = MidiSettings.new(31)
  GUITAR_HARMONICS = MidiSettings.new(32)
  
  ACOUSTIC_BASS = MidiSettings.new(33)
  ELECTRIC_BASS_FINGER = MidiSettings.new(34)
  ELECTRIC_BASS_PICK = MidiSettings.new(35)
  FRETLESS_BASS = MidiSettings.new(36)
  SLAP_BASS_1 = MidiSettings.new(37)
  SLAP_BASS_2 = MidiSettings.new(38)
  SYNTH_BASS_1 = MidiSettings.new(39)
  SYNTH_BASS_2 = MidiSettings.new(40)

  VIOLIN = MidiSettings.new(41)
  VIOLA = MidiSettings.new(42)
  CELLO = MidiSettings.new(43)
  CONTRABASS = MidiSettings.new(44)
  TREMOLO_STRINGS = MidiSettings.new(45)
  PIZZICATO_STRINGS = MidiSettings.new(46)
  ORCHESTRAL_HARP = MidiSettings.new(47)
  TIMPANI = MidiSettings.new(48)
  STRING_ENSEMBLE_1 = MidiSettings.new(49)
  STRING_ENSEMBLE_2 = MidiSettings.new(50)
  SYNTH_STRINGS_1 = MidiSettings.new(51)
  SYNTH_STRINGS_2 = MidiSettings.new(52)
  
  CHOIR_AAHS = MidiSettings.new(53)
  VOICE_OOHS = MidiSettings.new(54)
  SYNTH_VOICE = MidiSettings.new(55)
  ORCHESTRA_HIT = MidiSettings.new(56)
  
  TRUMPET = MidiSettings.new(57)
  TROMBONE = MidiSettings.new(58)
  TUBA = MidiSettings.new(59)
  MUTED_TRUMPET = MidiSettings.new(60)
  FRENCH_HORN = MidiSettings.new(61)
  BRASS_SECTION = MidiSettings.new(62)
  SYNTH_BRASS_1 = MidiSettings.new(63)
  SYNTH_BRASS_2 = MidiSettings.new(64)
  
  SOPRANO_SAX = MidiSettings.new(65)
  ALTO_SAX = MidiSettings.new(66)
  TENOR_SAX = MidiSettings.new(67)
  BARITONE_SAX = MidiSettings.new(68)
  OBOE = MidiSettings.new(69)
  ENGLISH_HORN = MidiSettings.new(70)
  BASSOON = MidiSettings.new(71)
  CLARINET = MidiSettings.new(72)
  
  PICCOLO = MidiSettings.new(73)
  FLUTE = MidiSettings.new(74)
  RECORDER = MidiSettings.new(75)
  PAN_FLUTE = MidiSettings.new(76)
  BLOWN_BOTTLE = MidiSettings.new(77)
  SHAKUHACHI = MidiSettings.new(78)
  WHISTLE = MidiSettings.new(79)
  OCARINA = MidiSettings.new(80)
  
  LEAD_SQUARE = MidiSettings.new(81)
  LEAD_SAWTOOTH = MidiSettings.new(82)
  LEAD_CALLIOPE = MidiSettings.new(83)
  LEAD_CHIFF = MidiSettings.new(84)
  LEAD_CHARANG = MidiSettings.new(85)
  LEAD_VOICE = MidiSettings.new(86)
  LEAD_FIFTHS = MidiSettings.new(87)
  LEAD_PLUS_BASS = MidiSettings.new(88)
  
  PAD_NEW_AGE = MidiSettings.new(89)
  PAD_WARM = MidiSettings.new(90)
  PAD_POLYSYNTH = MidiSettings.new(91)
  PAD_CHOIR = MidiSettings.new(92)
  PAD_BOWED = MidiSettings.new(93)
  PAD_METALLIC = MidiSettings.new(94)
  PAD_HALO = MidiSettings.new(95)
  PAD_SWEEP = MidiSettings.new(96)
end

class Part
  def midi_settings
    find_settings(MidiSettings)
  end
end

end