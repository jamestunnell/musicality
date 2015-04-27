module Musicality
module Parsing
  class NoteNode < Treetop::Runtime::SyntaxNode
    def primitives env
      [ self.to_note ]
    end
    
    def to_note
      if more.empty?
        return Musicality::Note.new(duration.to_r)
      end

      pitches = []
      links = {}

      first_pl = more.first_pl
      more_pl = more.more_pl

      pitches.push first_pl.pitch.to_pitch
      unless first_pl.the_link.empty?
        links[pitches[-1]] = first_pl.the_link.to_link
      end

      more_pl.elements.each do |x|
        pitches.push x.pl.pitch.to_pitch
        unless x.pl.the_link.empty?
          links[pitches[-1]] = x.pl.the_link.to_link
        end
      end
      
      artic = Musicality::Articulations::NORMAL
      unless more.art.empty?
        artic = more.art.to_articulation
      end

      accent_flag = !more.acc.empty?
      Musicality::Note.new(duration.to_r, pitches,
        links: links, articulation: artic, accented: accent_flag)
    end
  end
end
end