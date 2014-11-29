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
end
