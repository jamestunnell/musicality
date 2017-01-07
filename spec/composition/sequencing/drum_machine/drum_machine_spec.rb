require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe DrumMachine do
  describe '#initialize' do
    context 'no patterns given' do
      it 'should raise ArgumentError' do
        expect { DrumMachine.new([]) }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#next_part_notes' do
    context '1 pattern' do
      before :each do
        @pattern_dur = 1
        @pattern = DrumPattern.new({ "X" => [1,2] }, @pattern_dur)
        @dm = DrumMachine.new([@pattern])
      end

      context 'target duration equal to the pattern duration' do
        context 'next not called yet' do
          it 'should produce the part_notes from the pattern' do
            @dm.next_part_notes(@pattern_dur).should eq(@pattern.part_notes)
          end
        end

        context 'next already called once' do
          it 'should produce the part_notes from the pattern' do
            @dm.next_part_notes(@pattern_dur)
            @dm.next_part_notes(@pattern_dur).should eq(@pattern.part_notes)
          end
        end
      end
    end

    context '2 patterns' do
      before :each do
        @pattern1_dur = 1
        @pattern1 = DrumPattern.new({ "X" => [1,2] }, @pattern1_dur)
        @pattern2_dur = 2
        @pattern2 = DrumPattern.new({ "X" => [3,2] }, @pattern2_dur)
        @dm = DrumMachine.new([ @pattern1, @pattern2 ])
      end

      context 'next not called yet' do
        context 'given target duration equal to duration of first pattern' do
          it 'should produce the part_notes from the first pattern' do
            @dm.next_part_notes(@pattern1_dur).should eq(@pattern1.part_notes)
          end
        end
      end

      context 'next already called once with target duration of first pattern' do
        context 'given target duration equal to duration of second pattern' do
          it 'should produce the part_notes from the second pattern' do
            @dm.next_part_notes(@pattern1_dur)
            @dm.next_part_notes(@pattern2_dur).should eq(@pattern2.part_notes)
          end
        end
      end

      context 'next already called twice with target durations of each pattern' do
        context 'given target duration equal to duration of first pattern' do
          it 'should produce the part_notes from the first pattern' do
            @dm.next_part_notes(@pattern1_dur)
            @dm.next_part_notes(@pattern2_dur)
            @dm.next_part_notes(@pattern1_dur).should eq(@pattern1.part_notes)
          end
        end
      end
    end
  end
end
