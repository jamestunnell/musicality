require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe NoteArrays do
  describe '#initialize' do
    context 'given empty array' do
      it 'should raise ArgumentError' do
        expect { NoteArrays.new([]) }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#next_notes' do
    context '1 note array' do
      before :each do
        @notes1 = [ Note.whole, Note.half, Note.half ]
        @note_arrays = NoteArrays.new([@notes1])
      end

      context 'next_notes not called yet' do
        it 'should produce the only note array' do
          @note_arrays.next_notes.should eq(@notes1)
        end
      end

      context 'next already called once' do
        it 'should produce the only note array' do
          @note_arrays.next_notes
          @note_arrays.next_notes.should eq(@notes1)
        end
      end
    end

    context '2 note arrays' do
      before :each do
        @notes1 = [ Note.whole, Note.quarter ]
        @notes2 = [ Note.quarter, Note.eighth, Note.eighth]
        @note_arrays = NoteArrays.new([@notes1, @notes2])
      end

      context 'next_notes not called yet' do
        it 'should produce the first note array' do
          @note_arrays.next_notes.should eq(@notes1)
        end
      end

      context 'next_notes already called once' do
        it 'should produce the second note array' do
          @note_arrays.next_notes
          @note_arrays.next_notes.should eq(@notes2)
        end
      end

      context 'next_notes already called twice' do
        it 'should produce the first note array' do
          @note_arrays.next_notes
          @note_arrays.next_notes
          @note_arrays.next_notes.should eq(@notes1)
        end
      end
    end
  end

  describe '#reset' do
    context '3 note arrays' do
      before :each do
        @notes1 = [ Note.eighth, Note.eighth, Note.quarter ]
        @notes2 = [ Note.whole, Note.quarter ]
        @notes3 = [ Note.quarter, Note.eighth, Note.eighth]
        @note_arrays = NoteArrays.new([@notes1, @notes2, @notes3])
      end

      context 'next_notes not called yet' do
        it 'should have no effect, so a follow-up call to #next_notes still returns first notes array' do
          @note_arrays.reset
          @note_arrays.next_notes.should eq(@notes1)
        end
      end

      context 'next_notes already called once' do
        it 'should result in a follow-up call to #next_notes returning the first note array' do
          @note_arrays.next_notes
          @note_arrays.reset
          @note_arrays.next_notes.should eq(@notes1)
        end
      end

      context 'next_notes already called twice' do
        it 'should result in a follow-up call to #next_notes returning the first note array' do
          @note_arrays.next_notes
          @note_arrays.next_notes
          @note_arrays.reset
          @note_arrays.next_notes.should eq(@notes1)
        end
      end
    end
  end
end
