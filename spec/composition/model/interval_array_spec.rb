require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe IntervalArray::Absolute do
  it 'should be an Array' do
    IntervalArray::Absolute.new([1,2,3,4]).should be_an Array
  end
  
  describe '#to_pitches' do
    before :all do
      @base_pitches = [Db2,G7,B4]
      @ia = IntervalArray::Absolute.new([-4,-2,0,2,4,35,-24])
      @pitch_arrays = @base_pitches.map {|p| @ia.to_pitches(p) }
    end

    it 'should return an array of pitches with size equal # of intervals' do
      @pitch_arrays.each do |pitches|
        pitches.should be_a Array
        pitches.size.should eq(@ia.size)
        pitches.each {|p| p.should be_a Pitch }
      end
    end
    
    it 'should make each pitch from transposing the base pitch by the interval' do
      @pitch_arrays.each_with_index do |pitches,i|
        base_pitch = @base_pitches[i]
        pitches.each_with_index do |pitch,j|
          pitch.diff(base_pitch).should eq @ia[j]
        end
      end
    end
  end

  describe '#to_pcs' do
    before :all do
      @ia = IntervalArray::Absolute.new([4,5,-3,0,14,-55])
      @base_pcs = [0,3,-3,11,-11]
      @pcs_arrays = @base_pcs.map {|pc| @ia.to_pcs(pc) }
    end
  
    it 'should return an array of integers with size equal # of intervals' do
      @pcs_arrays.each do |pcs|
        pcs.should be_a Array
        pcs.size.should eq(@ia.size)
        pcs.each {|pc| pc.should be_a Integer }
      end
    end
    
    it 'should make each pc by adding the base pitch to the interval, then converting to pitch class' do
      @pcs_arrays.each_with_index do |pcs,i|
        base_pc = @base_pcs[i]
        pcs.each_with_index do |pc,j|
          pc.should eq((@ia[j] + base_pc).to_pc)
        end
      end
    end
  end
end

describe IntervalArray::Relative do
  it 'should be an Array' do
    IntervalArray::Relative.new([2,2,1,2]).should be_an Array
  end
  
  describe '#to_pitches' do
    before :all do
      @base_pitches = [Db2,G7,B4]
      @ia = IntervalArray::Relative.new([2,-2,11,-9,3,1,0])
      @pitch_arrays = @base_pitches.map {|p| @ia.to_pitches(p) }
    end

    it 'should return an array of pitches with size equal # of intervals' do
      @pitch_arrays.each do |pitches|
        pitches.should be_a Array
        pitches.size.should eq(@ia.size)
        pitches.each {|p| p.should be_a Pitch }
      end
    end
    
    it 'should make each pitch from transposing the base pitch by the interval' do
      @pitch_arrays.each_with_index do |pitches,i|
        prev_pitch = @base_pitches[i]
        pitches.each_with_index do |pitch,j|
          pitch.diff(prev_pitch).should eq @ia[j]
          prev_pitch = pitch
        end
      end
    end
  end

  describe '#to_pcs' do
    before :all do
      @ia = IntervalArray::Relative.new([1,3,2,3])
      @base_pcs = [0,3,-3,11,-11]
      @pcs_arrays = @base_pcs.map {|pc| @ia.to_pcs(pc) }
    end
  
    it 'should return an array of integers with size equal # of intervals' do
      @pcs_arrays.each do |pcs|
        pcs.should be_a Array
        pcs.size.should eq(@ia.size)
        pcs.each {|pc| pc.should be_a Integer }
      end
    end
    
    it 'should make each pc by adding the base pitch to the interval, then converting to pitch class' do
      @pcs_arrays.each_with_index do |pcs,i|
        prev_pc = @base_pcs[i]
        pcs.each_with_index do |pc,j|
          pc.should eq((@ia[j] + prev_pc).to_pc)
          prev_pc = pc
        end
      end
    end
  end
end
