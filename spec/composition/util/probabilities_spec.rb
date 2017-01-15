require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

require 'set'

describe Probabilities do
  [:random,:uniform].each do |class_method|
    describe ".#{class_method}" do
      it 'should return array of given size, with sum of 1' do
        (1..10).step(2) do |n|
          5.times do
            x = Probabilities.send(class_method,n)
            expect(x.size).to eq(n)
            expect(x.inject(0,:+)).to eq(1)
          end
        end
      end
    end
  end

  describe '.random' do
    it 'should return array of all-different values' do
      x = Probabilities.random(100)
      expect(Set.new(x).size).to eq(100)
    end
  end

  describe '.uniform' do
    it 'should return array of all (or all-but-one) same values' do
      [2,6,10,33,78,100].each do |n|
        x = Probabilities.uniform(n)
        y = Set.new(x)
        expect(y.size == 1 || y.size == 2).to eq(true)
        if y.size == 2
          expect(y.entries[0]).to be_within(1e-9).of(y.entries[1])
        end
      end
    end
  end
end
