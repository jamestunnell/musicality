require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Function::Constant do
  it 'should always return the same value' do
    f = Function::Constant.new(20)
    f.at(0).should eq(20)
    f.at(-1000).should eq(20)
    f.at(1000).should eq(20)
  end
end

describe Function::Linear do
  it 'should evaluate along the line going between the two initial points' do
    f = Function::Linear.new([5,10],[7,11])
    f.at(4).should eq(9.5)
    f.at(5).should eq(10)
    f.at(6).should eq(10.5)
    f.at(7).should eq(11)
    f.at(8).should eq(11.5)
  end
end

describe Function::Sigmoid do
  it 'should evaluate along the line going between the two initial points' do
    f = Function::Sigmoid.new([5,10],[7,11])
    f.at(4).should be < 10
    f.at(5).should eq(10)
    f.at(6).should eq(10.5)
    f.at(7).should eq(11)
    f.at(8).should be > 11
  end
  
  describe '.find_y0' do
    it 'should return the starting y-value for the given sigmoid domain' do
      x0, x1 = 3, 6
      y0, y1 = 5, 10
      f = Function::Sigmoid.new([x0,y0],[x1,y1])
      pt = [4,f.at(4)]
      y0_ = Function::Sigmoid.find_y0(x0..x1, pt, y1)
      y0_.should eq(y0)
    end
  end
end
