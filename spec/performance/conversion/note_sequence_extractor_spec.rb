
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

    it 'should remove any links where the source pitch does not exist in the note' do
      extr = NoteSequenceExtractor.new(
        [ Note.quarter([E4], links: {C4 => Link::Tie.new}),
          Note.quarter([C4,E4]) ]
      )
      extr.notes[0].links.should_not have_key(C4)

      extr = NoteSequenceExtractor.new(
        [ Note.quarter([E4], links: {C4 => Link::Glissando.new(G4)}),
          Note.quarter([C4,E4,G4]) ]
      )
      extr.notes[0].links.should_not have_key(C4)

      extr = NoteSequenceExtractor.new(
        [ Note.quarter([E4], links: {C4 => Link::Portamento.new(G4)}),
          Note.quarter([C4,E4,G4]) ]
      )
      extr.notes[0].links.should_not have_key(C4)
    end

    it 'should keep glissando/portamento links even when the target pitch does not exist in the next note.' do
      extr = NoteSequenceExtractor.new(
        [ Note.quarter([C4], links: {C4 => Link::Glissando.new(G4)}),
          Note.quarter([E4]) ]
      )
      extr.notes[0].links.should have_key(C4)

      extr = NoteSequenceExtractor.new(
        [ Note.quarter([C4], links: {C4 => Link::Portamento.new(G4)}),
          Note.quarter([E4]) ]
      )
      extr.notes[0].links.should have_key(C4)
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

      it 'should have start offset of 0' do
        @seqs[0].start.should eq 0
      end

      it 'should have stop offset <= note duration' do
        @seqs[0].stop.should be <= @note.duration
      end
    end

    context 'array with two slurred notes, single pitch' do
      before :all do
        @notes = [ Note.quarter([C5], marks: [BEGIN_SLUR]),
                   Note.quarter([D5], marks: [END_SLUR]) ]
        @seqs = NoteSequenceExtractor.new(@notes).extract_sequences
      end

      it 'should return array with one sequence' do
        @seqs.size.should eq 1
      end

      it 'should have start offset of 0' do
        @seqs[0].start.should eq 0
      end

      it 'should have stop offset <= combined duration of the two notes' do
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

      it 'should put one element in each seq' do
        @seqs.each {|s| s.elements.size.should eq(1) }
      end

      it 'should assign a different pitch to each' do
        @seqs.map {|seq| seq.elements.first.pitch }.sort.should eq @note.pitches.sort
      end
    end

    context 'array with multiple notes and links' do
      before :all do
        @notes = [
          Note.quarter([C3,E3], links: { C3 => Link::Tie.new, 
            E3 => Link::Glissando.new(G3)}),
          Note.eighth([C3,G3])
        ]
        @seqs = NoteSequenceExtractor.new(@notes).extract_sequences
      end

      it 'should create a single sequence for linked notes' do
        @seqs.size.should eq(2)
      end

      it 'should set first element pitch to match first note' do
        @seqs[0].elements.first.pitch.should eq(@notes[0].pitches[0])
        @seqs[1].elements.first.pitch.should eq(@notes[0].pitches[1])
      end

      it 'should collapse tie link to a single element' do
        @seqs[0].elements.size.should eq(1)
        @seqs[0].duration.should be <= (@notes[0].duration + @notes[1].duration)
      end

      it 'should expand the glissando into multiple elements' do
        @seqs[1].elements.size.should be > 2
        @seqs[1].duration.should be <= (@notes[0].duration + @notes[1].duration)
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
        @seqs[0].elements.map{|e| e.pitch}.should include(D3,Eb3,E3,F3,Gb3)
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
        @seqs[0].elements.map{|e| e.pitch}.should include(D3,Db3,C3,B2,Bb2)
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
        @seqs[0].elements.map{|e| e.pitch}.should include(D3,Eb3,E3,F3,Gb3,G3)
      end

      it 'should produce sequence with duration <= note1dur + note2dur' do
        @seqs[0].duration.should be <= (@notes[0].duration + @notes[1].duration)
      end
    end

    context 'three notes with single pitch, tie between first two, portamento between last two' do
      before :all do
        @notes = "/8Eb4~ /8Eb4:C5 3/4C5".to_notes
        @seqs = NoteSequenceExtractor.new(@notes).extract_sequences
      end

      it 'should produce a single sequence' do
        expect(@seqs.size).to eq(1)
      end

      it 'should have same full duration as the notes together' do
        expected_dur = @notes.map {|n| n.duration }.inject(0,:+)
        seq = @seqs.first
        expect(seq.full_duration).to eq(expected_dur)
      end

      it 'should have duration less than the notes together' do
        max_dur = @notes.map {|n| n.duration }.inject(0,:+)
        seq = @seqs.first
        expect(seq.duration).to be < max_dur
      end
    end
  end
end
