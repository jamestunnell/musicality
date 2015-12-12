module Musicality

class LilypondSettings
  include Packable

  attr_reader :instrument_name, :clefs, :transpose_interval

  def initialize instrument_name, clefs: [Clef::TREBLE, Clef::BASS], transpose_interval: 0
    raise ArgumentError unless (clefs & CLEFS) == clefs
    @instrument_name = instrument_name
    @clefs = clefs
    @transpose_interval = transpose_interval
  end

  def self.treble_bass(instrument_name, transpose_interval: 0)
    new(instrument_name, clefs: [Clef::TREBLE, Clef::BASS], transpose_interval: transpose_interval)
  end

  def self.treble(instrument_name, transpose_interval: 0)
    new(instrument_name, clefs: [Clef::TREBLE], transpose_interval: transpose_interval)
  end

  def self.bass(instrument_name, transpose_interval: 0)
    new(instrument_name, clefs: [Clef::BASS], transpose_interval: transpose_interval)
  end

  def self.guitar(instrument_name)
    new(instrument_name, clefs: [Clef::TENOR], transpose_interval: 12)
  end

  def self.bass_guitar(instrument_name)
    new(instrument_name, clefs: [Clef::BASS], transpose_interval: 12)
  end

  ACOUSTIC_GRAND_PIANO = LilypondSettings.treble_bass("Acoustic Grand Piano")
  BRIGHT_ACOUSTIC_PIANO = LilypondSettings.treble_bass("Bright Acoustic Piano")
  ELECTRIC_GRAND_PIANO = LilypondSettings.treble_bass("Electric Grand Piano")
  HONKY_TONK_PIANO = LilypondSettings.treble_bass("Honky Tonk Piano")
  ELECTRIC_PIANO = LilypondSettings.treble_bass("Electric Piano")
  HARPSICHORD = LilypondSettings.treble_bass("Harpsichord")
  CLAVINET = LilypondSettings.treble_bass("Clavinet")
  CELESTA = LilypondSettings.treble_bass("Celesta", transpose_interval: -12)

  GLOCKENSPIEL = LilypondSettings.treble_bass("Glockenspiel", transpose_interval: -24)
  MUSIC_BOX = LilypondSettings.treble_bass("Music Box")
  VIBRAPHONE = LilypondSettings.treble_bass("Virbaphone")
  MARIMBA = LilypondSettings.treble_bass("Marimba")
  XYLOPHONE = LilypondSettings.treble_bass("Xylophone", transpose_interval: -12)
  TUBULAR_BELLS = LilypondSettings.treble_bass("Tubular Bells")
  DULCIMER = LilypondSettings.treble("Dulcimer")

  DRAWBAR_ORGAN = LilypondSettings.treble_bass("Drawbar Organ")
  PERCUSSIVE_ORGAN = LilypondSettings.treble_bass("Percussive Organ")
  ROCK_ORGAN = LilypondSettings.treble_bass("Rock Organ")
  CHURCH_ORGAN = LilypondSettings.treble_bass("Church Organ")
  REED_ORGAN = LilypondSettings.treble_bass("Reed Organ")
  ACCORDIAN = LilypondSettings.treble_bass("Accordion")
  HARMONICA = LilypondSettings.treble("Harmonica")
  TANGO_ACCORDIAN = LilypondSettings.treble_bass("Tango Accordion")

  ACOUSTIC_GUITAR = LilypondSettings.guitar('Acoustic Guitar')
  ELECTRIC_GUITAR = LilypondSettings.guitar('Electric Guitar')
  OVERDRIVEN_GUITAR = LilypondSettings.guitar('Overdriven Guitar')
  DISTORTION_GUITAR = LilypondSettings.guitar('Distortion Guitar')
  GUITAR_HARMONICS = LilypondSettings.guitar('Guitar Harmonics')
  
  ACOUSTIC_BASS = LilypondSettings.bass_guitar('Acoustic Bass')
  ELECTRIC_BASS = LilypondSettings.bass_guitar('Electric Bass')
  FRETLESS_BASS = LilypondSettings.bass_guitar('Fretless Bass')
  SLAP_BASS = LilypondSettings.bass_guitar('Slap Bass')
  SYNTH_BASS = LilypondSettings.bass_guitar('Synth Bass')

  VIOLIN = LilypondSettings.treble('Violin')
  VIOLA = LilypondSettings.new('Viola', clefs: [Clef::TREBLE, Clef::ALTO])
  CELLO = LilypondSettings.new('Cello', clefs: [Clef::BASS, Clef::TENOR])
  CONTRABASS = LilypondSettings.bass('Contrabass', transpose_interval: 12)
  TREMOLO_STRINGS = LilypondSettings.treble_bass('Tremolo Strings')
  PIZZICATO_STRINGS = LilypondSettings.treble_bass('Pizzicato Strings')
  ORCHESTRAL_HARP = LilypondSettings.treble_bass('Orchestral Harp')
  TIMPANI = LilypondSettings.bass('Timpani')
  STRING_ENSEMBLE = LilypondSettings.treble_bass('String Ensemble')
  
  TRUMPET = LilypondSettings.treble('Trumpet', transpose_interval: 2)
  TROMBONE = LilypondSettings.new('Trombone', clefs: [Clef::BASS, Clef::TENOR])
  TUBA = LilypondSettings.bass('Tuba')
  FRENCH_HORN = LilypondSettings.bass('French Horn')
  
  SOPRANO_SAX = LilypondSettings.treble('Soprano Sax', transpose_interval: 2)
  ALTO_SAX = LilypondSettings.treble('Alto Sax', transpose_interval: 9)
  TENOR_SAX = LilypondSettings.treble('Tenor Sax', transpose_interval: 14)
  BARITONE_SAX = LilypondSettings.treble('Baritone Sax', transpose_interval: 21)
  OBOE = LilypondSettings.treble('Oboe')
  ENGLISH_HORN = LilypondSettings.treble('English Horn', transpose_interval: 7)
  BASSOON = LilypondSettings.bass('Bassoon')
  CLARINET = LilypondSettings.treble('Clarinet', transpose_interval: 2)
  PICCOLO = LilypondSettings.treble('Piccolo', transpose_interval: -12)
end

class Part
  def lilypond_settings
    find_settings(LilypondSettings)
  end
end

end