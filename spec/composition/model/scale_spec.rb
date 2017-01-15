require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

include PitchClasses

describe Scale do
  before :all do
    @intervals = [2,2,1,2,2,2,1]
    @pc = C
    @scale = Scale.new(@pc,@intervals)
  end

  describe '#pitch_class' do
    it 'should return the pitch class given to #initialize' do
      expect(@scale.pitch_class).to eq(@pc)
    end
  end

  describe '#size' do
    it 'should return the size of the scale intervals' do
      expect(@scale.size).to eq(@intervals.size)
    end
  end

  describe '#transpose' do
    before :all do
      @diff2 = 3
      @scale2 = @scale.transpose(@diff2)
      @diff3 = -5
      @scale3 = @scale.transpose(@diff3)
    end

    it 'should return a new Scale' do
      expect(@scale2).to be_a Scale
      expect(@scale2).to_not be @scale
      expect(@scale3).to be_a Scale
      expect(@scale3).to_not be @scale
    end

    it 'should return a scale with same intervals' do
      expect(@scale2.intervals).to eq @scale.intervals
      expect(@scale3.intervals).to eq @scale.intervals
    end

    it 'should return a scale with a shifted pitch class' do
      expect(@scale2.pitch_class).to eq((@scale.pitch_class + @diff2).to_pc)
      expect(@scale3.pitch_class).to eq((@scale.pitch_class + @diff3).to_pc)
    end
  end

  describe '#rotate' do
    before :all do
      @n2 = 5
      @scale2 = @scale.rotate(@n2)
      @n3 = -3
      @scale3 = @scale.rotate(@n3)
    end

    it 'should return a new Scale' do
      expect(@scale2).to be_a Scale
      expect(@scale2).to_not be @scale
      expect(@scale3).to be_a Scale
      expect(@scale3).to_not be @scale
    end

    it 'should return a scale with rotated intervals' do
      expect(@scale2.intervals).to eq @scale.intervals.rotate(@n2)
      expect(@scale3.intervals).to eq @scale.intervals.rotate(@n3)
    end

    it 'should return a scale with a shifted pitch class' do
      pc2 = (AddingSequence.new(@scale.intervals).at(@n2) + @scale.pitch_class).to_pc
      expect(@scale2.pitch_class).to eq(pc2)
      pc3 = (AddingSequence.new(@scale.intervals).at(@n3) + @scale.pitch_class).to_pc
      expect(@scale3.pitch_class).to eq(pc3)
    end
  end

  describe '#at_octave' do
    before :all do
      @octave = 2
      @pitch_seq = @scale.at_octave(@octave)
      @start_pitch = @pitch_seq.at(0)
    end

    it 'should return a bi-infinite sequence' do
      expect(@pitch_seq).to be_a BiInfiniteSequence
    end

    it 'should start sequence at scale pitch class and given octave' do
      expect(@start_pitch.semitone).to eq(@scale.pitch_class)
      expect(@start_pitch.octave).to eq(@octave)
    end

    it 'should make sequence that proceeds forwards along scale intervals' do
      first_pitches = @pitch_seq.over(0..@scale.intervals.size).to_a
      first_pitches[1..-1].each_with_index do |pitch,i|
        diff = pitch.diff(first_pitches[i])
        expect(diff).to eq(@scale.intervals[i])
      end
    end

    it 'should make sequence that proceeds backwards along scale intervals' do
      first_pitches = @pitch_seq.over(-@scale.intervals.size..0).to_a
      first_pitches[1..-1].each_with_index do |pitch,i|
        diff = pitch.diff(first_pitches[i])
        expect(diff).to eq(@scale.intervals[i])
      end
    end
  end
end
