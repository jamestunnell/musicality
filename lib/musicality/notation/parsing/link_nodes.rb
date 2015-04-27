module Musicality
module Parsing
  class LinkNode < Treetop::Runtime::SyntaxNode; end

  class GlissandoNode < LinkNode
    def to_link
      Musicality::Link::Glissando.new(pitch.to_pitch)
    end
  end
  
  class PortamentoNode < LinkNode
    def to_link
      Musicality::Link::Portamento.new(pitch.to_pitch)
    end
  end
  
  class TieNode < LinkNode
    def to_link
      Musicality::Link::Tie.new
    end
  end  
end
end