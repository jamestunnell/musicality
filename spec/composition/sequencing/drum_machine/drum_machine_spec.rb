require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe DrumMachine do
  describe '#initialize' do
    context 'given no patterns' do
      it 'should raise ArgumentError' do
        expect { DrumMachine.new([]) }.to raise_error(ArgumentError)
      end
    end
  end
end
