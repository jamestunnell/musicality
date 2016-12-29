require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

def notes_duration(notes)
  notes.map {|note| note.duration }.inject(0, :+)
end

describe DrumPattern do
  describe '#initialize' do
    context 'no part_name_portions given' do
      it 'should produce no part_notes' do
        DrumPattern.new({}, 0).part_notes.should be_empty
      end
    end

    context 'one part_name_portions given' do
      context 'total duration of 0 given' do
        it 'should raise ArgumentError' do
          expect { DrumPattern.new({"X" => [1,1]}, 0) }.to raise_error(ArgumentError)
        end
      end

      context 'total duration of 1 given' do
        it 'should produce 1 part_notes with total duration of 1' do
          dp = DrumPattern.new({"X" => [1,1]}, 1)
          dp.part_notes.size.should eq(1)
          dp.part_notes.keys[0].should eq("X")
          notes_duration(dp.part_notes.values[0]).should eq(1)
        end
      end
    end

    context 'multiple part_name_portions given' do
      context 'total duration of 2 given' do
        it 'should produce as many part_notes as were given, all with total duration of 2' do
          dp = DrumPattern.new( {"X" => [1,1], "Y" => [1,1,3] }, 2)
          dp.part_notes.size.should eq(2)
          dp.part_notes.keys.should include("X")
          dp.part_notes.keys.should include("Y")
          dp.part_notes.values.each do |notes|
            notes_duration(notes).should eq(2)
          end
        end
      end
    end
  end
end
