require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe DrumMachine do
  describe '#initialize' do
    context 'given no patterns' do
      it 'should raise ArgumentError' do
        expect { DrumMachine.new([]) }.to raise_error(ArgumentError)
      end
    end

    context 'given 1 pattern with 2 parts' do
      before :all do
        @pattern = DrumPattern.new(1, DrumParts::SNARE_DRUM => [1,2,1], DrumParts::CLOSED_HI_HAT => [1,1])
        @dm = DrumMachine.new([@pattern])
      end

      it 'should produce a NoteArray sequenceables for each part in pattern' do
        expect(@dm.part_sequenceables).to have_key(DrumParts::SNARE_DRUM)
        expect(@dm.part_sequenceables[DrumParts::SNARE_DRUM]).to be_a NoteArray

        expect(@dm.part_sequenceables).to have_key(DrumParts::CLOSED_HI_HAT)
        expect(@dm.part_sequenceables[DrumParts::CLOSED_HI_HAT]).to be_a NoteArray
      end

      it 'should provide part notes from the pattern to the NoteArray' do
        expect(@dm.part_sequenceables[DrumParts::SNARE_DRUM].notes).to eq(@pattern.part_notes[DrumParts::SNARE_DRUM])
        expect(@dm.part_sequenceables[DrumParts::CLOSED_HI_HAT].notes).to eq(@pattern.part_notes[DrumParts::CLOSED_HI_HAT])
      end
    end

    context 'given 2 patterns' do
      context 'first pattern contains only part DrumParts::SNARE_DRUM, second pattern contains only part DrumParts::CLOSED_HI_HAT' do
        before :all do
          @pattern1 = DrumPattern.new(2, DrumParts::SNARE_DRUM => [1,2,1])
          @pattern2 = DrumPattern.new(1, DrumParts::CLOSED_HI_HAT => [1,1])
          @dm = DrumMachine.new([@pattern1, @pattern2])
        end

        it 'should produce a NoteArray sequenceables for each part in pattern' do
          expect(@dm.part_sequenceables).to have_key(DrumParts::SNARE_DRUM)
          expect(@dm.part_sequenceables[DrumParts::SNARE_DRUM]).to be_a NoteArray

          expect(@dm.part_sequenceables).to have_key(DrumParts::CLOSED_HI_HAT)
          expect(@dm.part_sequenceables[DrumParts::CLOSED_HI_HAT]).to be_a NoteArray
        end

        it 'should start part DrumParts::SNARE_DRUM with notes from the first pattern' do
          first_notes = @pattern1.part_notes[DrumParts::SNARE_DRUM]
          expect(@dm.part_sequenceables[DrumParts::SNARE_DRUM].notes.slice(0...-1)).to eq(first_notes)
        end

        it 'should end part DrumParts::CLOSED_HI_HAT with notes from the second pattern' do
          last_notes = @pattern2.part_notes[DrumParts::CLOSED_HI_HAT]
          expect(@dm.part_sequenceables[DrumParts::CLOSED_HI_HAT].notes.slice(1..-1)).to eq(last_notes)
        end

        it 'should start part DrumParts::CLOSED_HI_HAT with a rest note that has same duration as the first pattern' do
          expect(@dm.part_sequenceables[DrumParts::CLOSED_HI_HAT].notes.first).to eq(Note.new(@pattern1.duration))
        end

        it 'should end part DrumParts::SNARE_DRUM with a rest note that has same duration as the second pattern' do
          expect(@dm.part_sequenceables[DrumParts::SNARE_DRUM].notes.last).to eq(Note.new(@pattern2.duration))
        end
      end
    end
  end
end
