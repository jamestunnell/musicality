require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe RandomRhythmGenerator do
  describe '#initialize' do
    context 'given probabilities that do not add up to 1' do
      it 'should raise ArgumentError' do
        [{ 1 => 0.4, 2 => 0.59 },
         { 1/2.to_r => 0.5, 1/4.to_r => 0.5001 }].each do |durs_w_probs|
          expect do
            RandomRhythmGenerator.new(durs_w_probs)
          end.to raise_error(ArgumentError)
        end
      end
    end
  end

  before :all do
    @rrgs = [
      { 1/8.to_r => 0.25, 1/4.to_r => 0.5, 1/2.to_r => 0.25 },
      { 1/6.to_r => 0.25, 1/4.to_r => 0.25, 1/3.to_r => 0.25, 1/12.to_r => 0.25 }
    ].map {|durs_w_probs| RandomRhythmGenerator.new(durs_w_probs) }
  end

  describe '#random_rhythm' do
    it 'should return durations that add to given total dur' do
      @rrgs.each do |rrg|
        [3,1,1/2.to_r,5/8.to_r,15/16.to_r].each do |total_dur|
          20.times do
            rhythm = rrg.random_rhythm(total_dur)
            expect(rhythm.inject(0,:+)).to eq(total_dur)
          end
        end
      end
    end
  end

  describe '#random_dur' do
    it 'should return a random duration, according to the probabilities given at initialization' do
      @rrgs.each do |rrg|
        counts = Hash[ rrg.durations.map {|dur| [dur,0] } ]
        1000.times { counts[rrg.random_dur] += 1 }
        rrg.durations.each_with_index do |dur,i|
          count = counts[dur]
          tgt_prob = rrg.probabilities[i]
          expect((count / 1000.to_f)).to be_within(0.05).of(tgt_prob)
        end
      end
    end
  end
end
