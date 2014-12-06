require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

patterns = [[1,2,3],[2,2,1,2,2,2,1],[-2,5,3,-5,2]]

describe Cycle do
  describe '#initialize' do
    context 'given empty pattern' do
      it 'should raise EmptyError' do
        expect { Cycle.new([]) }.to raise_error(EmptyError)
      end
    end
  end
  
  describe '#at' do
    it 'should return the pattern element at given offset (modulo by pattern size)' do
      patterns.each do |pattern|
        cycle = Cycle.new(pattern)
        [0,-1,1,2,-4,-7,-13,53,23,110].each do |offset|
          cycle.at(offset).should eq(pattern[offset % pattern.size])
        end
      end
    end
  end
  
  describe '#size' do
    it 'should return the size of the pattern' do
      patterns.each {|p| Cycle.new(p).size.should eq(p.size) }
    end
  end
  
  describe '#pattern' do
    context 'given a block' do
      it 'should yield only pattern elements' do
        cyc = Cycle.new(patterns[0])
        xs = []
        cyc.pattern do |x|
          xs.push x
        end
        xs.should eq(patterns[0])
      end
    end
    
    context 'not given a block' do
      it 'should return an enumerator for pattern elements' do
        cyc = Cycle.new(patterns[0])
        en = cyc.pattern
        en.should be_a Enumerator
        en.to_a.should eq(patterns[0])
      end
    end
  end
  
  describe '#over' do
    context 'given a block' do
      it 'should yield elements' do
        cyc = Cycle.new(patterns[0])
        xs = []
        cyc.over(0..1) do |x|
          xs.push x
        end
        xs.should eq(patterns[0][0..1])
      end
    end
    
    context 'not given a block' do
      it 'should return an enumerator' do
        cyc = Cycle.new(patterns[0])
        en = cyc.over 0..1
        en.should be_a Enumerator
        en.to_a.should eq(patterns[0][0..1])
      end
    end
    
    context 'first <= last' do
      it 'should return elements at offsets from first up to last (or last - 1 if exclusive range)' do
        patterns.each do |pattern|
          cycle = Cycle.new(pattern)
          [0..2,-5..-4,2..10,3..3,0...4,3...3,-4...44].each do |range|
            els = cycle.over(range).to_a
            els2 = range.map {|i| cycle.at(i) }
            els.should eq(els2)
          end
        end
      end
    end
    
    context 'first > last' do
      context 'given inclusive range' do
        it 'should return elements at offsets from last down to first' do
          patterns.each do |pattern|
            cycle = Cycle.new(pattern)
            [2..0,-3..-5,10..2,3..3].each do |range|
              els = cycle.over(range).to_a
              range2 = range.last..range.first
              els2 = range2.map {|i| cycle.at(i) }.reverse
              els.should eq(els2)
            end
          end
        end
      end
      
      context 'given exclusive range' do
        it 'should return elements at offsets from (last - 1) down to first' do
          patterns.each do |pattern|
            cycle = Cycle.new(pattern)
            [2...0,-3...-5,10...2,3...3].each do |range|
              els = cycle.over(range).to_a
              range2 = (range.last+1)..range.first
              els2 = range2.map {|i| cycle.at(i) }.reverse
              els.should eq(els2)
            end
          end
        end
      end
    end
  end
end
