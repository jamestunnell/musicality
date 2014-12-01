require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Transition do
  describe '#initialize' do
    context 'zero-length domain' do
      it 'should create one piece' do
        t = Transition.new(Function::Constant.new(3),5..5)
        t.pieces.size.should eq(1)
      end
    end
    
    context 'positive-length domain' do
      it 'should create two pieces' do
        t = Transition.new(Function::Linear.new([0,0],[2,1]),3..5)
        t.pieces.size.should eq(2)
      end
    end
  end
  
  describe '#at' do
    before :all do
      @f = Function::Linear.new([0,0],[2,1])
      @d = 3..5
      @t = Transition.new(@f,@d)
    end
    
    context 'given value before transition domain starts' do
      it 'should raise DomainError' do
        expect { @t.at(@d.first - 1e-5) }.to raise_error(DomainError)
        expect { @t.at(@d.first - 1e5) }.to raise_error(DomainError)
      end
    end
    
    context 'given value in transition domain' do
      it 'should not raise DomainError' do
        @d.entries.each {|x| expect { @t.at(x) }.to_not raise_error }
      end
      
      it 'should calculate return value using the transition function' do
        @d.entries.each {|x| @t.at(x).should eq(@f.at(x)) }
      end
    end
    
    context 'given value after transition domain' do
      it 'should return same value as at the end of transition domain' do
        @t.at(@d.last + 1e-5).should eq(@t.at(@d.last))
        @t.at(@d.last + 1e5).should eq(@t.at(@d.last))
      end
    end
  end
end