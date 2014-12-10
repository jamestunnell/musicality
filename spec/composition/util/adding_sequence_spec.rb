require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe AddingSequence do
  describe '#initialize' do
    context 'given an empty pattern' do
      it 'should raise EmptyError' do
        expect do
          AddingSequence.new([])
        end.to raise_error(EmptyError)
      end
    end
  end
  
  before :all do
    @pattern = [2,-1,5,-4,3]
    @start_value = 13
    @seq = AddingSequence.new(@pattern,@start_value)
  end
  
  describe '#at' do
    context 'given offset of 0' do
      it 'should return the start value' do
        [ 0, -3, 7].each do |start_val|
          AddingSequence.new(@pattern,start_val).at(0).should eq(start_val)
        end
      end
    end
    
    context 'given offset > 0' do
      it 'should keep adding on pattern elements to start_val until the given offset is reached' do
        [1,2,3,5,8,15,45].each do |offset|
          val = @seq.at(offset)
          rep_seq = RepeatingSequence.new(@pattern)
          val2 = rep_seq.take(offset).inject(@start_value,:+)
          val.should eq(val2)
        end
      end
    end
    
    context 'given offset < 0' do
      it 'should keep suctracting pattern elements from start_val until the given offset is reached' do
        [-1,-2,-3,-5,-8,-15,-45].each do |offset|
          val = @seq.at(offset)
          rep_seq = RepeatingSequence.new(@pattern)
          val2 = rep_seq.take_back(-offset).inject(@start_value,:-)
          val.should eq(val2)
        end
      end
    end
  end

  describe '#take' do
    context 'given negative integer' do
      it 'should raise NegativeError' do
        expect { @seq.take(-1) }.to raise_error(NegativeError)
        expect { @seq.take(-10) }.to raise_error(NegativeError)
      end
    end
    
    context 'given 0' do
      it 'should return empty array' do
        @seq.take(0).to_a.should eq([])
      end
    end
    
    context 'given positive integer' do
      context 'given block' do
        it 'should yield the given number of sequence elements in forward direction (repeating as necessary)' do
          i, m = 0, @pattern.size*2+3
          @seq.take(m) do |n|
            n.should eq(@seq.at(i))
            i += 1
          end
          i.should eq(m)
        end
      end
      
      context 'no block given' do
        it 'should return an enumerator' do
          @seq.take(20).should be_a Enumerator
        end
      end
    end
  end
  
  describe '#take_back' do
    context 'given negative integer' do
      it 'should raise NegativeError' do
        expect { @seq.take_back(-1) }.to raise_error(NegativeError)
        expect { @seq.take_back(-10) }.to raise_error(NegativeError)
      end
    end
    
    context 'given 0' do
      it 'should return empty array' do
        @seq.take_back(0).to_a.should eq([])
      end
    end
    
    context 'given positive integer' do
      context 'given block' do
        it 'should yield the given number of pattern elements in backward direction (repeating as necessary)' do
          i, m = 0, @pattern.size*2+3
          @seq.take_back(m) do |n|
            n.should eq(@seq.at(i-1))
            i -= 1
          end
          (-i).should eq(m)
        end
      end
      
      context 'no block given' do
        it 'should return an enumerator' do
          @seq.take_back(20).should be_a Enumerator
        end
      end
    end
  end
  
  describe '#over' do
    context 'given empty (invalid) range' do
      it 'should raise EmptyError' do
        [ 3...-2, 0...0, 5..2, -3..-5 ].each do |range|
          expect { @seq.over(range) }.to raise_error(EmptyError)
        end
      end
    end
    
    context 'given range over positive indices' do
      it 'should return seq values at all offsets in range' do
        [ 0..0, 0..2, 1...10, 4..17 ].each do |range|
          vals = @seq.over(range).to_a
          vals2 = range.map {|i| @seq.at(i) }
          vals.should eq(vals2)
        end
      end
    end
    
    context 'given negative min and/or max' do
      it 'should return seq values at all offsets in range' do
        [ -5..2, -10..-7, -1...1 ].each do |range|
          vals = @seq.over(range).to_a
          vals2 = range.map {|i| @seq.at(i) }
          vals.should eq(vals2)
        end
      end
    end
  end
end
