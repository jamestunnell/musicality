module Musicality

# Connect one note pitch to the target pitch of the next note, via slur, legato, etc.
#
# @!attribute [rw] target_pitch
#   @return [Pitch] The pitch of the note which is being connected to.
#
class Link
  def clone
    Marshal.load(Marshal.dump(self))
  end

  def transpose diff
    self.clone.transpose! diff
  end
  
  def transpose! diff
    return self
  end

  def ==(other)
    self.class == other.class
  end

  def to_s
    self.class::LINK_CHAR
  end

  class Tie < Link
    LINK_CHAR = LINK_SYMBOLS[Links::TIE]
  end

  class TargetedLink < Link
    attr_accessor :target_pitch
    
    def initialize target_pitch
      @target_pitch = target_pitch
    end
    
    def ==(other)
      super && @target_pitch == other.target_pitch
    end
    
    def transpose diff
      self.clone.transpose! diff
    end
    
    def transpose! diff
      @target_pitch = @target_pitch.transpose(diff)
      return self
    end
    
    def to_s
      super + @target_pitch.to_s
    end
  end
  
  class Glissando < TargetedLink
    LINK_CHAR = LINK_SYMBOLS[Links::GLISSANDO]
  end
  
  class Portamento < TargetedLink
    LINK_CHAR = LINK_SYMBOLS[Links::PORTAMENTO]
  end

  class Slur < TargetedLink
    LINK_CHAR = LINK_SYMBOLS[Links::SLUR]
  end

  class Legato < TargetedLink
    LINK_CHAR = LINK_SYMBOLS[Links::LEGATO]
  end
end

end
