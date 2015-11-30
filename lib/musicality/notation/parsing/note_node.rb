module Musicality
module Parsing
  class NoteNode < Treetop::Runtime::SyntaxNode
    def to_note
      dur = duration.to_r

      if more.empty?
        return Musicality::Note.new(dur)
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

      marks = []
      unless begin_marks.empty?
        marks.push begin_marks.first.to_mark
        unless begin_marks.second.empty?
          marks.push begin_marks.second.to_mark
        end
      end

      unless end_marks.empty?
        marks.push end_marks.first.to_mark
        unless end_marks.second.empty?
          marks.push end_marks.second.to_mark
        end
      end

      Musicality::Note.new(dur, pitches, links: links, marks: marks,
        articulation: more.art.empty? ? Articulations::NORMAL : more.art.to_articulation)
    end
  end
end
end