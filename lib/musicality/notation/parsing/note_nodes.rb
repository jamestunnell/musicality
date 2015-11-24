module Musicality
module Parsing
  class SingleNoteNode < Treetop::Runtime::SyntaxNode
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

      Musicality::Note.new(dur, pitches, links: links, 
        articulation: more.art.empty? ? Articulations::NORMAL : more.art.to_articulation,
        slur_mark: more.sl.empty? ? SlurMarks::NONE  : more.sl.to_slur_mark)
    end
  end
end
end