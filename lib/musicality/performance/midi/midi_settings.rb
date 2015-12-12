module Musicality

class MidiSettings
  include Packable

  attr_reader :program

  def initialize program
    @program = program
  end

  ELECTRIC_GUITAR_JAZZ = MidiSettings.new(27)
  ELECTRIC_BASS_FINGER = MidiSettings.new(34)
  ELECTRIC_BASS_PICK = MidiSettings.new(35)
  CLARINET = MidiSettings.new(72)
end

end