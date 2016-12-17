require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe RhythmClass do
  describe '.new' do
    it 'should raise ArgumentError if given portions contains any zero(s)' do
      expect { RhythmClass.new([1,0,2]) }.to raise_error(ArgumentError)
    end
  end

  describe '#portions' do
    it 'should return the same portions given initially' do
      portions = [4,2,-2,-1]
      rc = RhythmClass.new(portions)
      rc.portions.should eq(portions)
    end
  end

  describe '#portions_sum' do
    it 'should return the sum of portions using their absolute value' do
      rc = RhythmClass.new([4,2,-2,-1])
      rc.portions_sum.should eq(9)
    end
  end

  describe '#to_rhythm' do
    it 'should produce the expected Rhythm object' do
      portions = [5,1,-7,3,-1,2]
      rhythm_class = RhythmClass.new(portions)
      portions_sum = rhythm_class.portions_sum
      rhythm_duration = 2
      rhythm = rhythm_class.to_rhythm(rhythm_duration)

      rhythm.should be_a(Rhythm)
      rhythm.durations.size.should eq(portions.size)
      portions.each_with_index do |portion, idx|
        dur = rhythm.durations[idx]
        dur.should eq(rhythm_duration * Rational(portion, portions_sum))
      end
      rhythm.durations_sum.should eq(rhythm_duration)
    end
  end
end
