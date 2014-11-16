module Musicality
module Parsing
  class LinkNode < Treetop::Runtime::SyntaxNode; end
    
  class SlurNode < LinkNode
    def to_link
      Musicality::Link::Slur.new(target.to_pitch)
    end
  end

  class LegatoNode < LinkNode
    def to_link
      Musicality::Link::Legato.new(target.to_pitch)
    end
  end

  class GlissandoNode < LinkNode
    def to_link
      Musicality::Link::Glissando.new(target.to_pitch)
    end
  end
  
  class PortamentoNode < LinkNode
    def to_link
      Musicality::Link::Portamento.new(target.to_pitch)
    end
  end
  
  class TieNode < LinkNode
    def to_link
      Musicality::Link::Tie.new
    end
  end  
end
end