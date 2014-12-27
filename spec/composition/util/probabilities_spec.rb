require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

require 'set'

describe Probabilities do
  [:random,:uniform].each do |class_method|
    describe ".#{class_method}" do
      it 'should return array of given size, with sum of 1' do
        (1..10).step(2) do |n|
          5.times do
            x = Probabilities.send(class_method,n)
            x.size.should eq(n)
            x.inject(0,:+).should eq(1)
          end
        end
      end
    end
  end
  
  describe '.random' do
    it 'should return array of all-different values' do
      x = Probabilities.random(100)
      Set.new(x).size.should eq(100)
    end
  end
  
  describe '.uniform' do
    it 'should return array of all (or all-but-one) same values' do
      [2,6,10,33,78,100].each do |n|
        x = Probabilities.uniform(n)
        y = Set.new(x)
        (y.size == 1 || y.size == 2).should eq(true)
        if y.size == 2
          y.entries[0].should be_within(1e-9).of(y.entries[1])
        end
      end
    end
  end
end
