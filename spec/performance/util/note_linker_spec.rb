require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe NoteLinker do
  describe '.find_unlinked_pitches' do
    {
      'note has no pitches' => [Note.quarter,[]],
      'note has 1 pitch, no links' => [Note.quarter([C4]),[C4]],
      'note has 2 pitches, no links' => [Note.quarter([C4,E4]),[C4,E4]],
      'note has 1 pitch, which is linked' => [Note.quarter([C4], links: {C4 => Link::Tie.new} ),[]],
      'note has 2 pitch, 1 of which is linked' => [Note.quarter([C4,E4], links: {C4 => Link::Tie.new} ),[E4]],
      'note has 2 pitches, both of which are linked' => [Note.quarter([C4,E4], links: {C4 => Link::Tie.new, E4 => Link::Tie.new} ),[]],
      'note has 1 pitch, and 1 unrelated link' => [Note.quarter([C4], links: {D4 => Link::Tie.new}),[C4]],
      'note has 2 pitch, and 2 unrelated links' => [Note.quarter([C4,E4], links: {D4 => Link::Tie.new, F4 => Link::Tie.new}),[C4,E4]],
    }.each do |descr,given_expected|
      context descr do
        given, expected = given_expected
        it "should return #{expected}" do
          actual = NoteLinker.find_unlinked_pitches(given)
          actual.should eq(expected)
        end
      end
    end
  end
  
  describe '.find_untargeted_pitches' do
    {
      'note has no pitches, next note has no pitches' => [Note.quarter,Note.quarter,[]],
      'note has no pitches, next note has 3 pitch' => [Note.quarter,Note.quarter([C3,E3,F3]),[C3,E3,F3]],
      'note has 3 pitches + no links, next note has 2 pitches' => [Note.quarter([C3,E3,F3]),Note.quarter([D2,F2]),[D2,F2]],
      'note has 1 pitch + 1 unrelated link, next note has 1 pitch' => [Note.quarter([C3], links: {C3 => Link::Slur.new(C2)}),Note.quarter([D2]),[D2]],
      'note has 1 pitch + 1 related link, next note has 1 pitch' => [Note.quarter([C3], links: {C3 => Link::Slur.new(D2)}),Note.quarter([D2]),[]],
      'note has 2 pitches + 2 related link, next note has 2 pitches' => [Note.quarter([C3,E3], links: {C3 => Link::Slur.new(D2), E3 => Link::Slur.new(E2) }),Note.quarter([D2,E2]),[]],
      'note has 2 pitches + 1 unrelated link, next note has 2 pitches' => [Note.quarter([C3,E3], links: {C3 => Link::Slur.new(D2), E3 => Link::Slur.new(F2) }),Note.quarter([D2,E2]),[E2]],
    }.each do |descr,given_expected|
      context descr do
        given_note, given_next_note, expected = given_expected
        it "should return #{expected}" do
          actual = NoteLinker.find_untargeted_pitches(given_note, given_next_note)
          actual.should eq(expected)
        end
      end
    end    
  end
  
  describe '.fully_link' do
    [
      [ Note.quarter([C4,E4,G4]), Note.quarter, Note.quarter([C4,E4,G4]) ],
      [ Note.quarter([G4]), Note.quarter([A4]), Note.quarter([G4], links: {G4 => Link::Slur.new(A4)}) ],
      [
        Note.quarter([G4,A4]),
        Note.quarter([A4]),
        Note.quarter([G4,A4], links: {A4 => Link::Slur.new(A4)})
      ],
      [
        Note.quarter([G4,A4], links: {A4 => Link::Slur.new(B4)}),
        Note.quarter([A4,B4]),
        Note.quarter([G4,A4], links: {G4 => Link::Slur.new(A4), A4 => Link::Slur.new(B4)})
      ],
    ].each do |note,next_note,modified|
      context "given note: #{note.to_s}, next_note: #{next_note.to_s}" do
        it "should modifiy note to equal #{modified.to_s}" do
          NoteLinker.fully_link(note, next_note, Link::Slur)
          note.should eq(modified)
        end
      end
    end
  end
end
