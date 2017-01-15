require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe NoteArray do
  describe '#initialize' do
    context 'given empty array' do
      it 'should raise ArgumentError' do
        expect { NoteArray.new([]) }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#next_note' do
    context '1 note in array' do
      before :each do
        @note = Note.whole
        @note_array = NoteArray.new([@note])
      end

      context 'next_note not called yet' do
        it 'should produce the only note in the array' do
          expect(@note_array.next_note).to eq(@note)
        end
      end

      context 'next already called once' do
        it 'should produce the only note array' do
          @note_array.next_note
          expect(@note_array.next_note).to eq(@note)
        end
      end
    end

    context '2 notes in array' do
      before :each do
        @notes = [ Note.whole, Note.quarter ]
        @note_array = NoteArray.new(@notes)
      end

      context 'next_note not called yet' do
        it 'should produce the first note' do
          expect(@note_array.next_note).to eq(@notes[0])
        end
      end

      context 'next_note already called once' do
        it 'should produce the second note' do
          @note_array.next_note
          expect(@note_array.next_note).to eq(@notes[1])
        end
      end

      context 'next_note already called twice' do
        it 'should produce the first note' do
          @note_array.next_note
          @note_array.next_note
          expect(@note_array.next_note).to eq(@notes[0])
        end
      end
    end
  end

  describe '#reset' do
    context '3 notes in array' do
      before :each do
        @notes = [ Note.eighth, Note.eighth, Note.quarter ]
        @note_array = NoteArray.new(@notes)
      end

      context 'next_note not called yet' do
        it 'should have no effect, so a follow-up call to #next_note still returns first note' do
          @note_array.reset
          expect(@note_array.next_note).to eq(@notes[0])
        end
      end

      context 'next_note already called once' do
        it 'should result in a follow-up call to #next_note returning the first note' do
          @note_array.next_note
          @note_array.reset
          expect(@note_array.next_note).to eq(@notes[0])
        end
      end

      context 'next_note already called twice' do
        it 'should result in a follow-up call to #next_note returning the first note' do
          @note_array.next_note
          @note_array.next_note
          @note_array.reset
          expect(@note_array.next_note).to eq(@notes[0])
        end
      end
    end
  end
end
