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
      @scale.pitch_class.should eq(@pc)
    end
  end
  
  describe '#size' do
    it 'should return the size of the scale intervals' do
      @scale.size.should eq(@intervals.size)
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
      @scale2.should be_a Scale
      @scale2.should_not be @scale
      @scale3.should be_a Scale
      @scale3.should_not be @scale
    end
    
    it 'should return a scale with same intervals' do
      @scale2.intervals.should eq @scale.intervals
      @scale3.intervals.should eq @scale.intervals
    end
    
    it 'should return a scale with a shifted pitch class' do
      @scale2.pitch_class.should eq((@scale.pitch_class + @diff2).to_pc)
      @scale3.pitch_class.should eq((@scale.pitch_class + @diff3).to_pc)
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
      @scale2.should be_a Scale
      @scale2.should_not be @scale
      @scale3.should be_a Scale
      @scale3.should_not be @scale
    end
    
    it 'should return a scale with rotated intervals' do
      @scale2.intervals.should eq @scale.intervals.rotate(@n2)
      @scale3.intervals.should eq @scale.intervals.rotate(@n3)
    end
    
    it 'should return a scale with a shifted pitch class' do
      pc2 = (AddingSequence.new(@scale.intervals).at(@n2) + @scale.pitch_class).to_pc
      @scale2.pitch_class.should eq(pc2)
      pc3 = (AddingSequence.new(@scale.intervals).at(@n3) + @scale.pitch_class).to_pc
      @scale3.pitch_class.should eq(pc3)
    end
  end
  
  describe '#at_octave' do
    before :all do
      @octave = 2
      @pitch_seq = @scale.at_octave(@octave)
      @start_pitch = @pitch_seq.at(0)
    end
  
    it 'should return a bi-infinite sequence' do
      @pitch_seq.should be_a BiInfiniteSequence
    end
    
    it 'should start sequence at scale pitch class and given octave' do
      @start_pitch.semitone.should eq(@scale.pitch_class)
      @start_pitch.octave.should eq(@octave)
    end
    
    it 'should make sequence that proceeds forwards along scale intervals' do
      first_pitches = @pitch_seq.over(0..@scale.intervals.size).to_a
      first_pitches[1..-1].each_with_index do |pitch,i|
        diff = pitch.diff(first_pitches[i])
        diff.should eq(@scale.intervals[i])
      end
    end
    
    it 'should make sequence that proceeds backwards along scale intervals' do
      first_pitches = @pitch_seq.over(-@scale.intervals.size..0).to_a
      first_pitches[1..-1].each_with_index do |pitch,i|
        diff = pitch.diff(first_pitches[i])
        diff.should eq(@scale.intervals[i])
      end
    end
  end
end