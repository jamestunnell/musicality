require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe RandomSampler do
  describe '#initialize' do
    context 'given probabilities that do not add up to 1' do
      it 'should raise ArgumentError' do
        [ [[1,2],[0.4,0.59]],
          [[1/2.to_r, 1/4.to_r],[0.5,0.5001]] ].each do |vals,probs|
          expect { RandomSampler.new(vals,probs) }.to raise_error(ArgumentError)
        end
      end
    end
  end

  before :all do
    @samplers = [
      [[ 1/8.to_r, 1/4.to_r, 1/2.to_r ], [0.25, 0.5, 0.25 ]],
      [[ 1/6.to_r, 1/4.to_r, 1/3.to_r, 1/12.to_r], [0.25,0.25,0.25,0.25]]
    ].map {|vals,probs| RandomSampler.new(vals,probs) }
  end

  describe '#random_dur' do
    it 'should return a random duration, according to the probabilities given at initialization' do
      @samplers.each do |sampler|
        counts = Hash[ sampler.values.map {|val| [val,0] } ]
        1000.times { counts[sampler.sample] += 1 }
        sampler.values.each_with_index do |val,i|
          count = counts[val]
          tgt_prob = sampler.probabilities[i]
          (count / 1000.to_f).should be_within(0.05).of(tgt_prob)
        end
      end
    end
  end
end
