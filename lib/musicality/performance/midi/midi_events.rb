module Musicality

class MidiEvent
  def <=> other
    ORDERING[self] <=> ORDERING[other]
  end
  
  class NoteOn < MidiEvent
    attr_reader :notenum, :attack
    def initialize notenum, attack
      @notenum, @attack = notenum, attack
    end
  end
  
  class NoteOff < MidiEvent
    attr_reader :notenum
    def initialize notenum
      @notenum = notenum
    end
  end
  
  class Expression < MidiEvent
    attr_reader :volume
    def initialize volume
      @volume = volume
    end
  end
  
  ORDERING = {
    NoteOff => 0, Expression => 1, NoteOn => 2
  }
end

end