require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe IntervalVector do
  describe '.new' do
    it 'should raise error if no intervals are given' do
      lambda { IntervalVector.new([]) }.should raise_error
    end
  end
  
  it 'should be an Array' do
    IntervalVector.new([1,2,3,4]).should be_an Array
  end
  
  describe '#invert' do
    it 'should return an interval vector with all the intervals negated' do
      intervals = [3,4,-12,0,-4,3]
      iv = IntervalVector.new(intervals)
      iv2 = iv.invert
      iv2.should be_a IntervalVector
      iv2.each_with_index do |int,i|
        int.should eq(-intervals[i])
      end
    end
  end
  
  describe '#shift' do
    it 'should return an interval vector with with the given offset add to each interval' do
      intervals = [4,5,-3,0,14,-55]
      iv = IntervalVector.new(intervals)
      [0,3,-3,11,-11].each do |offset|
        iv2 = iv.shift(offset)
        iv2.should be_a IntervalVector
        iv2.each_with_index do |pc,i|
          pc.should eq(intervals[i] + offset)
        end
      end
    end
  end
  
  describe '#to_pitches' do
    before :all do
      @base_pitches = [Db2,G7,B4]
      @iv = IntervalVector.new([-4,-2,0,2,4,35,-24])
      @pitch_arrays = @base_pitches.map {|p| @iv.to_pitches(p) }
    end

    it 'should return an array of pitches with size equal # of intervals' do
      @pitch_arrays.each do |pitches|
        pitches.should be_a Array
        pitches.size.should eq(@iv.size)
        pitches.each {|p| p.should be_a Pitch }
      end
    end
    
    it 'should make each pitch from transposing the base pitch by the interval' do
      @pitch_arrays.each_with_index do |pitches,i|
        base_pitch = @base_pitches[i]
        pitches.each_with_index do |pitch,j|
          pitch.diff(base_pitch).should eq @iv[j]
        end
      end
    end
  end

  describe '#to_pcs' do
    before :all do
      @iv = IntervalVector.new([4,5,-3,0,14,-55])
      @base_pcs = [0,3,-3,11,-11]
      @pcs_arrays = @base_pcs.map {|pc| @iv.to_pcs(pc) }
    end
  
    it 'should return an array of integers with size equal # of intervals' do
      @pcs_arrays.each do |pcs|
        pcs.should be_a Array
        pcs.size.should eq(@iv.size)
        pcs.each {|pc| pc.should be_a Integer }
      end
    end
    
    it 'should make each pc by adding the base pitch to the interval, then converting to pitch class' do
      @pcs_arrays.each_with_index do |pcs,i|
        base_pc = @base_pcs[i]
        pcs.each_with_index do |pc,j|
          pc.should eq((@iv[j] + base_pc).to_pc)
        end
      end
    end
  end
end
