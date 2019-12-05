require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

valid = [ [0,0,0], [-1,4,-3,8], [4,7], [1,2,3,4,5,6,7,8,9,10,11] ]

describe Intervals do
  describe '#initialize' do
    context 'given no offsets' do
      it 'should raise ArgumentError' do
        expect { Intervals.new([]) }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#offsets' do
    it 'should return offsets given to #initialize' do
      valid.each do |offsets|
        expect(Intervals.new(offsets).offsets).to eq(offsets)
      end
    end
  end

  describe '#==' do
    it 'should compare given enumerable to offsets' do
      valid.each do |offsets|
        intervals1 = Intervals.new(offsets)
        intervals2 = Intervals.new(offsets)
        intervals3 = Intervals.new(offsets.drop(1))
        expect(intervals1).to eq(intervals2)
        expect(intervals1).to_not eq(intervals3)
      end
    end
  end

  describe '#rotate' do
    {
      1 => [[4,7,9],[3,5,8]],
      2 => [[4,7,9],[2,5,9]],
      3 => [[4,7,9],[3,7,10]],
      4 => [[4,7,9],[4,7,9]],
      -1 => [[4,7,9],[3,7,10]],
      -2 => [[4,7,9],[2,5,9]],
      -3 => [[4,7,9],[3,5,8]],
      -4 => [[4,7,9],[4,7,9]]
    }.each do |rotate_n, start_finish|
      it "should rotate by #{rotate_n}" do
        intervals = Intervals.new(start_finish[0])
        expect(intervals.rotate(rotate_n).offsets).to eq(start_finish[1])
      end
    end

    it 'should rotate by 1, by default' do
      intervals = Intervals.new(valid.first)
      expect(intervals.rotate).to eq(intervals.rotate(1))
    end
  end

  describe '#each' do
    before :all do
      @intervals = Intervals.new(valid.first)
    end

    context 'block given' do
      it 'should yield all interval values' do
        xs = []
        @intervals.each do |x|
          xs.push(x)
        end
        expect(xs).to eq(@intervals.offsets)
      end
    end

    context 'no block given' do
      it 'should return an enumerator' do
        expect(@intervals.each).to be_a Enumerator
      end
    end
  end

  describe '#to_pitch_seq' do
    before :all do
      @intervals = Intervals.new([2,4,5,7,9,11])
      @start_pitch = C4
      @first_octave = [C4,D4,E4,F4,G4,A4,B4,C5]
      @prev_octave = [C3,D3,E3,F3,G3,A3,B3,C4]
      @pseq = @intervals.to_pitch_seq(@start_pitch)
    end

    it 'should return a AddingSequence' do
      expect(@pseq).to be_a AddingSequence
    end

    it 'should be centered at given start pitch' do
      expect(@pseq.at(0)).to eq(@start_pitch)
    end

    it 'should walk forward/backward through intervalsale' do
      expect(@pseq.take(8).to_a).to eq(@first_octave)
      expect(@pseq.over(0...8).to_a).to eq(@first_octave)
      expect(@pseq.take_back(7).to_a).to eq(@prev_octave.reverse.drop(1))
      expect(@pseq.over(-7..0).to_a).to eq(@prev_octave)
    end
  end
end
