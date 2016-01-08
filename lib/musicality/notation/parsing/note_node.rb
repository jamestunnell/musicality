module Musicality
module Parsing
  class NoteNode < Treetop::Runtime::SyntaxNode
    def to_note
      dur = duration.to_r
      pitches = []
      links = {}
      articulation = Articulations::NORMAL

      unless more.empty?
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

        unless more.art.empty?
          articulation = more.art.to_articulation
        end
      end

      marks = []
      unless begin_slur.empty?
        marks.push Musicality::Marks::BEGIN_SLUR
      end

      unless end_slur.empty?
        marks.push Musicality::Marks::END_SLUR
      end

      Musicality::Note.new(dur, pitches, links: links, marks: marks, articulation: articulation)
    end
  end
end
end