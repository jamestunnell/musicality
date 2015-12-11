module Musicality

# Connect one note pitch to the target pitch of the next note, via slur, legato, etc.
#
# @!attribute [rw] target_pitch
#   @return [Pitch] The pitch of the note which is being connected to.
#
class Link
  include Packable
  
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
    LINK_SYMBOLS[self.class]
  end

  class Tie < Link; end

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
  
  class Glissando < TargetedLink; end
  class Portamento < TargetedLink; end
end

end
