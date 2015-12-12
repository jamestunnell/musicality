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

  ELECTRIC_PIANO = LilypondSettings.new("Electric Piano")
  ELECTRIC_BASS = LilypondSettings.new("Electric Bass", clefs: [Clef::BASS], transpose_interval: 12)
  CLARINET = LilypondSettings.new("Clarinet", clefs: [Clef::TREBLE], transpose_interval: 2)
end

end