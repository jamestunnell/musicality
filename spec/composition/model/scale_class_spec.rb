require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

valid = [ [2,2,1,2,2,2,1], [1]*12 ]

describe ScaleClass do
  describe '#initialize' do
    context 'given intervals that do not sum to 12' do
      it 'should raise ArgumentError' do
        [ [], [1]*11, [2]*5, [7,7], [2,2,2,2,2,1] ].each do |intervals|
          expect { ScaleClass.new(intervals) }.to raise_error(ArgumentError)
        end
      end
    end
  end
  
  describe '#intervals' do
    it 'should return intervals given to #initialize' do
      valid.each do |intervals|
        ScaleClass.new(intervals).intervals.should eq(intervals)
      end
    end
  end
  
  describe '#==' do
    it 'should compare given enumerable to intervals' do
      valid.each do |intervals|
        sc = ScaleClass.new(intervals)
        sc.should eq(intervals)
        sc.should_not eq(intervals + [2])
      end
    end
  end
  
  describe '#rotate' do
    it 'should return a new ScaleClass, with rotated intervals' do
      valid.each do |intervals|
        sc = ScaleClass.new(intervals)
        [ 0, 1, -1, 4, -3, 2, 6 ].each do |n|
          sc2 = sc.rotate(n)
          sc2.should_not be(sc)
          sc2.should eq(intervals.rotate(n))
        end
      end
    end
    
    it 'should rotate by 1, by default' do
      intervals = valid.first
      ScaleClass.new(intervals).rotate.should eq(intervals.rotate(1))
    end
  end
  
  describe '#each' do
    before :all do
      @sc = ScaleClass.new(valid.first)
    end
    
    context 'block given' do
      it 'should yield all interval values' do
        xs = []
        @sc.each do |x|
          xs.push(x)
        end
        xs.should eq(@sc.intervals)
      end
    end
    
    context 'no block given' do
      it 'should return an enumerator' do
        @sc.each.should be_a Enumerator
      end
    end
  end
end