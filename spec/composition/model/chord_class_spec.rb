require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe ChordClass do
  describe '#initialize' do
    context 'given non-positive intervals' do
      it 'should raise NonPositiveError' do
        [[0,4,7],[-1,3,6],[-2,13]].each do |intervals|
          expect { ChordClass.new(intervals) }.to raise_error(NonPositiveError)
        end
      end
    end

    context 'given intervals >= 12' do
      it 'should not raise ArgumentError' do
        [[5,9,12],[1,11,13]].each do |intervals|
          expect { ChordClass.new(intervals) }.not_to raise_error
        end
      end
    end

    context 'given non-sorted intervals' do
      it 'should raise ArgumentError' do
        [[5,12,9],[13,11,1]].each do |intervals|
          expect { ChordClass.new(intervals) }.to raise_error(ArgumentError)
        end
      end
    end
  end
end
