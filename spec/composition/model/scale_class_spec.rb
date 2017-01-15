require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

valid = [ [2,2,1,2,2,2,1], [1]*12 ]

describe ScaleClass do
  describe '#initialize' do
    context 'given non-positive intervals' do
      it 'should raise NonPositiveError' do
        [ [3,6,-1,4], [-1,13], [4,4,4,-1,1] ].each do |intervals|
          expect { ScaleClass.new(intervals) }.to raise_error(NonPositiveError)
        end
      end
    end
  end

  describe '#intervals' do
    it 'should return intervals given to #initialize' do
      valid.each do |intervals|
        expect(ScaleClass.new(intervals).intervals).to eq(intervals)
      end
    end
  end

  describe '#==' do
    it 'should compare given enumerable to intervals' do
      valid.each do |intervals|
        sc = ScaleClass.new(intervals)
        expect(sc).to eq(intervals)
        expect(sc).to_not eq(intervals + [2])
      end
    end
  end

  describe '#rotate' do
    it 'should return a new ScaleClass, with rotated intervals' do
      valid.each do |intervals|
        sc = ScaleClass.new(intervals)
        [ 0, 1, -1, 4, -3, 2, 6 ].each do |n|
          sc2 = sc.rotate(n)
          expect(sc2).to_not be(sc)
          expect(sc2).to eq(intervals.rotate(n))
        end
      end
    end

    it 'should rotate by 1, by default' do
      intervals = valid.first
      expect(ScaleClass.new(intervals).rotate).to eq(intervals.rotate(1))
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
        expect(xs).to eq(@sc.intervals)
      end
    end

    context 'no block given' do
      it 'should return an enumerator' do
        expect(@sc.each).to be_a Enumerator
      end
    end
  end

  describe '#to_pitch_seq' do
    before :all do
      @sc = ScaleClass.new([2,2,1,2,2,2,1])
      @start_pitch = C4
      @first_octave = [C4,D4,E4,F4,G4,A4,B4,C5]
      @prev_octave = [C3,D3,E3,F3,G3,A3,B3,C4]
      @pseq = @sc.to_pitch_seq(@start_pitch)
    end

    it 'should return a AddingSequence' do
      expect(@pseq).to be_a AddingSequence
    end

    it 'should be centered at given start pitch' do
      expect(@pseq.at(0)).to eq(@start_pitch)
    end

    it 'should walk forward/backward through scale' do
      expect(@pseq.take(8).to_a).to eq(@first_octave)
      expect(@pseq.over(0...8).to_a).to eq(@first_octave)
      expect(@pseq.take_back(7).to_a).to eq(@prev_octave.reverse.drop(1))
      expect(@pseq.over(-7..0).to_a).to eq(@prev_octave)
    end
  end
end
