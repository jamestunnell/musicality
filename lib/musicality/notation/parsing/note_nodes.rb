module Musicality
module Parsing
  class TripletNoteNode < Treetop::Runtime::SyntaxNode
    def to_note
      Musicality::Triplet.new(first.to_note,
        second.to_note, third.to_note)
    end
  end

  class SingleNoteNode < Treetop::Runtime::SyntaxNode
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