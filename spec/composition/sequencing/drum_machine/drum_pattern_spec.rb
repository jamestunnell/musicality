require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

def notes_duration(notes)
  notes.map {|note| note.duration }.inject(0, :+)
end

describe DrumPattern do
  describe '#initialize' do
    context 'no part_name_portions given' do
      it 'should produce no part_notes' do
        DrumPattern.new(0, {}).part_notes.should be_empty
      end
    end

    context 'one part_name_portions given' do
      context 'total duration of 0 given' do
        it 'should raise ArgumentError' do
          expect { DrumPattern.new(0, "X" => [1,1]) }.to raise_error(ArgumentError)
        end
      end

      context 'total duration of 1 given' do
        it 'should produce 1 part_notes with total duration of 1' do
          dp = DrumPattern.new(1, "X" => [1,1])
          dp.part_notes.size.should eq(1)
          dp.part_notes.keys[0].should eq("X")
          notes_duration(dp.part_notes.values[0]).should eq(1)
        end
      end
    end

    context 'multiple part_name_portions given' do
      context 'total duration of 2 given' do
        before :all do
          @part_name_portions = {"X" => [1,1], "Y" => [1,1,3]}
          @duration = 2
          @dp = DrumPattern.new(@duration, @part_name_portions)
        end

        it 'should produce as many part_notes as were given' do
          @dp.part_notes.size.should eq(@part_name_portions.size)
        end

        it 'should produce part_notes that match given part_name_portions' do
          @part_name_portions.keys.each do |part_name|
            expect(@dp.part_notes).to have_key(part_name)
          end
        end

        it 'should produce all part_notes with total duration equal to that of pattern' do
          @dp.part_notes.values.each do |notes|
            notes_duration(notes).should eq(@duration)
          end
        end
      end
    end
  end
end
