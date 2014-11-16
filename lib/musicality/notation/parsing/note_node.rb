module Musicality
module Parsing
  class NoteNode < Treetop::Runtime::SyntaxNode
    def primitives env
      [ self.to_note ]
    end
    
    def to_note
      pitches = []
      links = {}
      
      unless pitch_links.empty?
        first = pitch_links.first
        more = pitch_links.more
        
        pitches.push first.pitch.to_pitch
        unless first.the_link.empty?
          links[pitches[-1]] = first.the_link.to_link
        end
        
        more.elements.each do |x|
          pitches.push x.pl.pitch.to_pitch
          unless x.pl.the_link.empty?
            links[pitches[-1]] = x.pl.the_link.to_link
          end
        end
      end
      
      artic = Musicality::Articulations::NORMAL
      unless art.empty?
        artic = art.to_articulation
      end
      
      accent_flag = acc.empty? ? false : true
      Musicality::Note.new(duration.to_r,
        pitches, links: links, articulation: artic, accented: accent_flag)
    end
  end
end
end