require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe DrumMachine do
  describe '#initialize' do
    context 'no patterns given' do
      it 'should raise ArgumentError' do
        expect { DrumMachine.new([]) }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#next' do
    context '1 pattern' do
      before :each do
        @patterns = [ DrumPattern.new({ "X" => [1,2] }, 1) ]
        @dm = DrumMachine.new(@patterns)
      end

      context 'next not called yet' do
        it 'should produce the part_notes from the pattern' do
          @dm.next.should eq(@patterns[0].part_notes)
        end
      end

      context 'next already called once' do
        it 'should produce the part_notes from the pattern' do
          @dm.next
          @dm.next.should eq(@patterns[0].part_notes)
        end
      end
    end

    context '2 patterns' do
      before :each do
        @patterns = [ DrumPattern.new({ "X" => [1,2] }, 1), DrumPattern.new({ "X" => [3,2] }, 2) ]
        @dm = DrumMachine.new(@patterns)
      end

      context 'next not called yet' do
        it 'should produce the part_notes from the first pattern' do
          @dm.next.should eq(@patterns[0].part_notes)
        end
      end

      context 'next already called once' do
        it 'should produce the part_notes from the second pattern' do
          @dm.next
          @dm.next.should eq(@patterns[1].part_notes)
        end
      end

      context 'next already called twice' do
        it 'should produce the part_notes from the first pattern' do
          @dm.next
          @dm.next
          @dm.next.should eq(@patterns[0].part_notes)
        end
      end
    end

    context '4 patterns' do
      before :each do
        @patterns = [
          DrumPattern.new({ "X" => [1,2] }, 1), DrumPattern.new({ "X" => [3,2] }, 2),
          DrumPattern.new({ "X" => [4,3,2] }, 1), DrumPattern.new({ "X" => [1,3,2] }, 2)
        ]
        @dm = DrumMachine.new(@patterns)
      end

      context 'next not called yet' do
        it 'should produce the part_notes from the first pattern' do
          @dm.next.should eq(@patterns[0].part_notes)
        end
      end

      context 'next already called once' do
        it 'should produce the part_notes from the second pattern' do
          @dm.next
          @dm.next.should eq(@patterns[1].part_notes)
        end
      end

      context 'next already called twice' do
        it 'should produce the part_notes from the third pattern' do
          @dm.next
          @dm.next
          @dm.next.should eq(@patterns[2].part_notes)
        end
      end

      context 'next already called three times' do
        it 'should produce the part_notes from the fourth pattern' do
          @dm.next
          @dm.next
          @dm.next
          @dm.next.should eq(@patterns[3].part_notes)
        end
      end

      context 'next already called four times' do
        it 'should produce the part_notes from the first pattern' do
          @dm.next
          @dm.next
          @dm.next
          @dm.next
          @dm.next.should eq(@patterns[0].part_notes)
        end
      end
    end
  end

  describe '#reset' do
    context '4 patterns' do
      before :each do
        @patterns = [
          DrumPattern.new({ "X" => [1,2] }, 1), DrumPattern.new({ "X" => [3,2] }, 2),
          DrumPattern.new({ "X" => [4,3,2] }, 1), DrumPattern.new({ "X" => [1,3,2] }, 2)
        ]
        @dm = DrumMachine.new(@patterns)
      end

      context 'next not called yet' do
        it 'should have no effect, so #next still returns the part_notes from the first sequence' do
          @dm.reset
          @dm.next.should eq(@patterns[0].part_notes)
        end
      end

      context 'next already called once' do
        it 'should result in #next returning the part_notes from the first pattern' do
          @dm.next
          @dm.reset
          @dm.next.should eq(@patterns[0].part_notes)
        end
      end

      context 'next already called twice' do
        it 'should result in #next returning the part_notes from the first pattern' do
          @dm.next
          @dm.next
          @dm.reset
          @dm.next.should eq(@patterns[0].part_notes)
        end
      end
    end
  end
end
