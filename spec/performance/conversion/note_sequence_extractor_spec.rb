
require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe NoteSequenceExtractor do
  describe '#initialize' do
    it 'should clone original notes' do
      notes = [ Note.quarter([C2]), Note.half, Note.half ]
      extr = NoteSequenceExtractor.new(notes)
      extr.notes[0].should eq(notes[0])
      notes[0].transpose!(1)
      extr.notes[0].should_not eq(notes[0])
    end

    it 'should maintain the same number of notes' do
      extr = NoteSequenceExtractor.new(
        [ Note.quarter, Note.half, Note.half ])
      extr.notes.size.should eq 3
    end

    it 'should remove any bad ties (tying pitch does not exist in next note' do
      extr = NoteSequenceExtractor.new(
        [ Note.quarter([C4,E4], links: {C4 => Link::Tie.new}),
          Note.quarter([E4]) ]
      )
      extr.notes[0].links.should_not have_key(C4)
    end

    it 'should replace any good ties with slurs' do
      extr = NoteSequenceExtractor.new(
        [ Note.quarter([C4,E4], links: {C4 => Link::Tie.new, E4 => Link::Tie.new}),
          Note.quarter([C4,E4]) ]
      )
      extr.notes[0].links[C4].should be_a Link::Slur
      extr.notes[0].links[E4].should be_a Link::Slur
    end

    it 'should remove dead slur/legato (where target pitch is non-existent)' do
      extr = NoteSequenceExtractor.new(
        [ Note.quarter([C4,E4], links: { C4 => Link::Slur.new(D4), E4 => Link::Legato.new(F4) }),
          Note.quarter([C4]) ]
      )
      extr.notes[0].links.should be_empty
    end

    it 'should remove any link where the source pitch is missing' do
      extr = NoteSequenceExtractor.new(
        [ Note.quarter([C4,D4,E4,F4,G4], links: {
            Bb4 => Link::Tie.new, Db4 => Link::Slur.new(C4),
            Eb4 => Link::Legato.new(D4), Gb4 => Link::Glissando.new(E4),
            Ab5 => Link::Portamento.new(F4)
          }),
          Note.quarter([C4,D4,E4,F4,G4])
      ])
      extr.notes[0].links.should be_empty
    end

    it 'should not remove portamento and glissando with non-existent target pitches' do
      extr = NoteSequenceExtractor.new(
        [ Note.quarter([C4,D4]),
          Note.quarter([C4,D4,E4,F4,G4], links: {
            C4 => Link::Tie.new, D4 => Link::Slur.new(Eb4),
            E4 => Link::Legato.new(Gb4), F4 => Link::Glissando.new(A5),
            G4 => Link::Portamento.new(Bb5)}) ]
      )
      extr.notes[-1].links.size.should eq 2
      extr.notes[-1].links.should have_key(F4)
      extr.notes[-1].links.should have_key(G4)
    end
  end

  describe '#extract_sequences' do
    context 'empty note array' do
      it 'should return empty' do
        seqs = NoteSequenceExtractor.new([]).extract_sequences
        seqs.should be_empty
      end
    end

    context 'array of only rest notes' do
      it 'should return empty' do
        notes = [ Note::quarter, Note::quarter ]
        seqs = NoteSequenceExtractor.new(notes).extract_sequences
        seqs.should be_empty
      end
    end

    context 'array with only one note, single pitch' do
      before :all do
        @note = Note::quarter([C5])
        @seqs = NoteSequenceExtractor.new([@note]).extract_sequences
      end

      it 'should return array with one sequence' do
        @seqs.size.should eq 1
      end

      it 'should start offset 0' do
        @seqs[0].start.should eq 0
      end

      it 'should stop offset <= note duration' do
        @seqs[0].stop.should be <= @note.duration
      end
    end

    context 'array with two slurred notes, single pitch' do
      before :all do
        @notes = [ Note.quarter([C5], articulation: SLUR), Note.quarter([D5]) ]
        @seqs = NoteSequenceExtractor.new(@notes).extract_sequences
      end

      it 'should return array with one sequence' do
        @seqs.size.should eq 1
      end

      it 'should start offset 0' do
        @seqs[0].start.should eq 0
      end

      it 'should stop offset <= combined duration of the two notes' do
        @seqs[0].stop.should be <= (@notes[0].duration + @notes[1].duration)
      end
    end

    context 'array with one note, multiple pitches' do
      before :all do
        @note = Note.quarter([C5,D5,E5])
        @seqs = NoteSequenceExtractor.new([@note]).extract_sequences
      end

      it 'should return array with as many sequences as pitches' do
        @seqs.size.should eq @note.pitches.size
      end

      it 'should start the sequences at 0' do
        @seqs.each {|s| s.start.should eq(0) }
      end

      it 'should end each sequence at or before note duration' do
        @seqs.each {|s| s.stop.should be <= @note.duration }
      end

      it 'should put one pitch in each seq' do
        @seqs.each {|s| s.pitches.size.should eq(1) }
      end

      it 'should assign a different pitch to each' do
        @seqs.map {|seq| seq.pitches[0] }.sort.should eq @note.pitches.sort
      end
    end

    context 'array with multiple notes and links' do
      before :all do
        @notes = [ Note.quarter([C3,E3], links: {
          C3 => Link::Slur.new(D3), E3 => Link::Legato.new(F3)}),
          Note.eighth([D3,F3]) ]
        @seqs = NoteSequenceExtractor.new(@notes).extract_sequences
      end

      it 'should create a sequence for linked notes' do
        @seqs.size.should eq(2)
      end

      it 'should add pitch at 0 from first note' do
        @seqs[0].pitches.should have_key(0)
        @notes[0].pitches.should include(@seqs[0].pitches[0])
        @seqs[1].pitches.should have_key(0)
        @notes[0].pitches.should include(@seqs[1].pitches[0])
      end
    end

    context 'single note with single pitch, and glissando up' do
      before :all do
        @note = Note.whole([D3], links: { D3 => Link::Glissando.new(G3) })
        @seqs = NoteSequenceExtractor.new([@note]).extract_sequences
      end

      it 'should produce one sequence' do
        @seqs.size.should eq(1)
      end

      it 'should include pitches up to (not including) target pitch' do
        @seqs[0].pitches.values.should include(D3,Eb3,E3,F3,Gb3)
      end

      it 'should produce sequence with duration <= note duration' do
        @seqs[0].duration.should be <= @note.duration
      end
    end

    context 'single note with single pitch, and glissando down' do
      before :all do
        @note = Note.whole([D3], links: { D3 => Link::Glissando.new(A2) })
        @seqs = NoteSequenceExtractor.new([@note]).extract_sequences
      end

      it 'should produce one sequence' do
        @seqs.size.should eq(1)
      end

      it 'should include pitches down to (not including) target pitch' do
        @seqs[0].pitches.values.should include(D3,Db3,C3,B2,Bb2)
      end

      it 'should produce sequence with duration <= note duration' do
        @seqs[0].duration.should be <= @note.duration
      end
    end

    context 'two notes with single pitch, glissando up to pitch in second note' do
      before :all do
        @notes = [Note.whole([D3], links: { D3 => Link::Glissando.new(G3) }),
                  Note.quarter([G3]) ]
        @seqs = NoteSequenceExtractor.new(@notes).extract_sequences
      end

      it 'should produce a single sequence' do
        @seqs.size.should eq(1)
      end

      it 'should includes pitches up through target pitch' do
        @seqs[0].pitches.values.should include(D3,Eb3,E3,F3,Gb3,G3)
      end

      it 'should produce sequence with duration <= note1dur + note2dur' do
        @seqs[0].duration.should be <= (@notes[0].duration + @notes[1].duration)
      end
    end
  end
end
