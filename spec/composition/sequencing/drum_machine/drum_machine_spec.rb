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
        @pattern = DrumPattern.new(1, "X" => [1,2,1], "Y" => [1,1])
        @dm = DrumMachine.new([@pattern])
      end

      it 'should produce a NoteArray sequenceables for each part in pattern' do
        expect(@dm.part_sequenceables).to have_key("X")
        expect(@dm.part_sequenceables["X"]).to be_a NoteArray

        expect(@dm.part_sequenceables).to have_key("Y")
        expect(@dm.part_sequenceables["Y"]).to be_a NoteArray
      end

      it 'should provide part notes from the pattern to the NoteArray' do
        expect(@dm.part_sequenceables["X"].notes).to eq(@pattern.part_notes["X"])
        expect(@dm.part_sequenceables["Y"].notes).to eq(@pattern.part_notes["Y"])
      end
    end

    context 'given 2 patterns' do
      context 'first pattern contains only part "X", second pattern contains only part "Y"' do
        before :all do
          @pattern1 = DrumPattern.new(2, "X" => [1,2,1])
          @pattern2 = DrumPattern.new(1, "Y" => [1,1])
          @dm = DrumMachine.new([@pattern1, @pattern2])
        end

        it 'should produce a NoteArray sequenceables for each part in pattern' do
          expect(@dm.part_sequenceables).to have_key("X")
          expect(@dm.part_sequenceables["X"]).to be_a NoteArray

          expect(@dm.part_sequenceables).to have_key("Y")
          expect(@dm.part_sequenceables["Y"]).to be_a NoteArray
        end

        it 'should start part "X" with notes from the first pattern' do
          first_notes = @pattern1.part_notes["X"]
          expect(@dm.part_sequenceables["X"].notes.slice(0...-1)).to eq(first_notes)
        end

        it 'should end part "Y" with notes from the second pattern' do
          last_notes = @pattern2.part_notes["Y"]
          expect(@dm.part_sequenceables["Y"].notes.slice(1..-1)).to eq(last_notes)
        end

        it 'should start part "Y" with a rest note that has same duration as the first pattern' do
          expect(@dm.part_sequenceables["Y"].notes.first).to eq(Note.new(@pattern1.duration))
        end

        it 'should end part "X" with a rest note that has same duration as the second pattern' do
          expect(@dm.part_sequenceables["X"].notes.last).to eq(Note.new(@pattern2.duration))
        end
      end
    end
  end
end
