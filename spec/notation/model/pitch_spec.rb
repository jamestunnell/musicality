require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Pitch do

  before :each do
    @cases = 
    [
      { :octave => 1, :semitone => 0, :cent => 0, :ratio => 2.0, :total_cents => 1200 },
      { :octave => 2, :semitone => 0, :cent => 0, :ratio => 4.0, :total_cents => 2400 },
      { :octave => 1, :semitone => 6, :cent => 0, :ratio => 2.828, :total_cents => 1800 },
      { :octave => 2, :semitone => 6, :cent => 0, :ratio => 5.657, :total_cents => 3000 },
      { :octave => 3, :semitone => 7, :cent => 0, :ratio => 11.986, :total_cents => 4300 },
      { :octave => -1, :semitone => 0, :cent => 0, :ratio => 0.5, :total_cents => -1200 },
      { :octave => -2, :semitone => 0, :cent => 0, :ratio => 0.25, :total_cents => -2400 },
      { :octave => -2, :semitone => 7, :cent => 0, :ratio => 0.37458, :total_cents => -1700 },
      { :octave => -1, :semitone => 9, :cent => 0, :ratio => 0.841, :total_cents => -300 },
      { :octave => 5, :semitone => 0, :cent => 20, :ratio => 32.372, :total_cents => 6020 },
      { :octave => 3, :semitone => 3, :cent => 95, :ratio => 10.0503, :total_cents => 3995 },
      { :octave => -3, :semitone => 2, :cent => -20, :ratio => 0.1387, :total_cents => -3420 },
      { :octave => -5, :semitone => -2, :cent => -77, :ratio => 0.02663, :total_cents => -6277 }
    ]
  end
  
  it "should be constructable with no parameters (no error raised)" do
    lambda { Pitch.new }.should_not raise_error
  end
  
  it "should take keyword args" do
    obj = Pitch.new octave: 4, semitone: 3, cent: 5
    obj.octave.should eq(4)
    obj.semitone.should eq(3)
    obj.cent.should eq(5)
  end
  
  it "should use default octave, semitone, and cent if none is given" do
    p = Pitch.new
    p.ratio.should be_within(0.01).of(1.0)
    p.total_cents.should eq(0)
  end
  
  it "should use the octave and semitone given during construction" do
    @cases.each do |case_data|
      p = Pitch.new octave: case_data[:octave], semitone: case_data[:semitone], cent: case_data[:cent]
      p.ratio.should be_within(0.01).of case_data[:ratio]
      p.total_cents.should be case_data[:total_cents]
    end
  end
  
  describe '#diff' do
    it 'should return the difference between the given pitch, in semitones' do
      [
	[C5,C4,12],
	[C5,D5,-2],
	[D5,C5,2],
	[C5,Pitch.new(octave:5, cent:-5),5/100.0],
	[A5,Pitch.new(octave:5, semitone: 5, cent: 22),378/100.0],
	[A5,Pitch.new(octave:5, semitone: 11, cent: 85),-285/100.0],
      ].each do |a,b,c|
	a.diff(b).should eq(c)
      end
    end
  end
  
  describe '#transpose' do
    it 'should make a new pitch, adding the given interval to total semitones' do
      [0,1,2,5,12,13,-1,-2,-5,-12,-13].each do |interval|
        pitch = Eb3.transpose(interval)
        pitch.should_not be Eb3
        pitch.diff(Eb3).should eq(interval)
      end
    end
  end
  
  describe '#+' do
    it 'should produce same result as #transpose' do
      [0,1,2,5,12,13,-1,-2,-5,-12,-13].each do |interval|
        pitch = Eb3 + interval
        pitch.should_not be Eb3
        pitch2 = Eb3.transpose(interval)
        pitch.should eq(pitch2)
      end
    end
  end

  describe '#-' do
    it 'should produce same result as #transpose, with negative interval' do
      [0,1,2,5,12,13,-1,-2,-5,-12,-13].each do |interval|
        pitch = Eb3 - interval
        pitch.should_not be Eb3
        pitch2 = Eb3.transpose(-interval)
        pitch.should eq(pitch2)
      end
    end
  end

  describe '.total_semitones' do
    it 'should convert to whole/fractional total semitones value' do
      C4.total_semitones.should eq(48)
      C5.total_semitones.should eq(60)
      C4.transpose(0.1).total_semitones.should eq(48.1)
      C5.transpose(0.19).total_semitones.should eq(60.19)
      C5.transpose(-0.19).total_semitones.should eq(59.81)
    end
  end
  
  describe '.from_semitones' do
    it 'should convert (rounded) fractional part to cent value' do
      Pitch.from_semitones(4).total_cents.should eq(400)
      Pitch.from_semitones(4.11).total_cents.should eq(411)
      Pitch.from_semitones(57.123).total_cents.should eq(5712)
      Pitch.from_semitones(57.125).total_cents.should eq(5713)
    end
  end
  
  describe '.from_ratio' do
    it 'should return a Pitch with given ratio' do
      @cases.each do |case_data|
        p = Pitch.from_ratio case_data[:ratio]
        p.total_cents.should eq case_data[:total_cents]
      end
    end
  end

  describe '.from_freq' do
    it 'should make a pitch whose freq is approximately the given freq' do
      [16.35, 440.0, 987.77].each do |given_freq|
	pitch = Pitch.from_freq given_freq
	pitch.freq.should be_within(0.01).of(given_freq)
      end
    end
  end
  
  it "should be comparable to other pitches" do
    p1 = Pitch.new semitone: 1
    p2 = Pitch.new semitone: 2
    p3 = Pitch.new semitone: 3

    p1.should eq(Pitch.new semitone: 1)
    p2.should eq(Pitch.new semitone: 2)
    p3.should eq(Pitch.new semitone: 3)
    
    p1.should be < p2
    p1.should be < p3
    p2.should be < p3
    p3.should be > p2
    p3.should be > p1
    p2.should be > p1
  end
  
  it "should have freq of 440 for A4" do
    a4 = Pitch.new octave: 4, semitone: 9
    a4.freq.should be_within(0.01).of(440.0)
  end
  
  describe '#to_yaml' do
    it 'should produce YAML that can be loaded' do
      p = Pitch.new(octave: 1, semitone: 2)
      YAML.load(p.to_yaml).should eq p
    end
  end
  
  describe '#to_s' do
    context 'on-letter semitones' do
      it 'should return the semitone letter + octave number' do
        { C0 => "C0", D1 => "D1", E7 => "E7",
          F8 => "F8", G3 => "G3", A4 => "A4",
          B5 => "B5", C2 => "C2" }.each do |p,s|
          p.to_s.should eq s
        end
      end
    end
    
    context 'off-letter semitones' do
      context 'sharpit set false' do
        it 'should return semitone letter + "b" + octave number' do
          { Db0 => "Db0", Eb1 => "Eb1", Gb7 => "Gb7",
            Ab4 => "Ab4", Bb1 => "Bb1" }.each do |p,s|
            p.to_s(false).should eq s
          end
        end
      end
      
      context 'sharpit set true' do
        it 'should return semitone letter + "#" + octave number' do
          { Db0 => "C#0", Eb1 => "D#1", Gb7 => "F#7",
            Ab4 => "G#4", Bb1 => "A#1" }.each do |p,s|
            p.to_s(true).should eq s
          end
        end
      end
    end
    
    context 'non-zero cent value' do
      it 'should append +n (n = cent value)' do
	{ C0.transpose(0.01) => "C0+1", E1.transpose(0.15) => "E1+15",
	  G5.transpose(-0.55) => "Gb5+45"
	}.each do |p,s|
	  p.to_s.should eq s
	end
      end
    end
  end
end
