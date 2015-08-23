module Musicality

class Instrument
  TREBLE = :treble
  BASS = :bass
  TENOR = :tenor
  ALTO = :alto
  CLEFS = [TREBLE, ALTO, BASS, TENOR]

  DEFAULT_MIDI_OPT = :default

  attr_accessor :name, :clefs, :midi_num, :transpose_interval

  def initialize name, clefs, midi_num, transpose_interval = 0
    @name = name
    @clefs = clefs
    @midi_num = midi_num
    @transpose_interval = transpose_interval
  end

  def ==(other)
    begin
      return name == other.name && 
        Set.new(clefs) == Set.new(other.clefs) && 
        midi_num == other.midi_num &&
        transpose_interval == other.transpose_interval
    rescue # if other object doesn't have the right methods
      return false
    end
  end

  def self.treble name, midi_num, transpose_interval = 0
    Instrument.new(name, [TREBLE], midi_num, transpose_interval)
  end

  def self.bass name, midi_num, transpose_interval = 0
    Instrument.new(name, [BASS], midi_num, transpose_interval)
  end

  def self.treble_bass name, midi_num, transpose_interval = 0
    Instrument.new(name, [TREBLE,BASS], midi_num, transpose_interval)
  end

  def self.treble_alto name, midi_num, transpose_interval = 0
    Instrument.new(name, [TREBLE,ALTO], midi_num, transpose_interval)
  end

  def self.tenor_bass name, midi_num, transpose_interval = 0
    Instrument.new(name, [TENOR, BASS], midi_num, transpose_interval)
  end

  def self.guitar name, midi_num
    Instrument.new(name, [TENOR], midi_num, 12)
  end

  def self.bass_guitar name, midi_num
    Instrument.new(name, [BASS], midi_num, 12)
  end
end

end
