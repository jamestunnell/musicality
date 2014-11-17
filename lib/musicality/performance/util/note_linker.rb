module Musicality

class NoteLinker
  def self.find_unlinked_pitches note
    linked = Set.new(note.pitches) & note.links.keys
    (Set.new(note.pitches) - linked).to_a
  end
  
  def self.find_untargeted_pitches note, next_note
    linked = Set.new(note.pitches) & note.links.keys
    targeted = Set.new(linked.map {|p| note.links[p].target_pitch })
    (Set.new(next_note.pitches) - targeted).to_a
  end
  
  def self.figure_links note, next_note
    unlinked = find_unlinked_pitches(note)
    untargeted = find_untargeted_pitches(note, next_note)
    Optimization.linking(unlinked, untargeted)
  end
  
  def self.fully_link note, next_note, link_class
    figure_links(note,next_note).each do |pitch,tgt_pitch|
      note.links[pitch] = link_class.new(tgt_pitch)
    end
  end  
end

end
