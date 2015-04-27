module Musicality
module Parsing
  class PitchNode < Treetop::Runtime::SyntaxNode
    def to_pitch
      
      modval = 0
      unless mod.empty?
        modval = case mod.text_value
        when "#" then 1
        when "b" then -1
        end
      end
      sem = (pitch_letter.to_semitone + modval) % Musicality::Pitch::SEMITONES_PER_OCTAVE

      oct = octave.to_i
      ncents = 0
      unless cents.empty?
        ncents = cents.to_i
      end
      
      Musicality::Pitch.new(semitone: sem, octave: oct, cent: ncents)
    end
  end
end
end