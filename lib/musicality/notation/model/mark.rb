module Musicality

class Mark
  include Packable
  
  def clone
    self.class.new
  end

  def to_s
    MARK_SYMBOLS[self.class]
  end

  def ==(other)
    self.class == other.class
  end

  class Slur < Mark
    class Begin < Slur
      def begins?; true; end
      def ends?; false; end
    end

    class End < Slur
      def begins?; false; end
      def ends?; true; end
    end
  end
end

end
