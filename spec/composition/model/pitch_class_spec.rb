require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

include PitchClasses

describe PitchClass do
  it 'should define the MOD constant' do
    PitchClass.constants.should include(:MOD)
  end
  
  describe '.from_i' do
    it 'should return the given integer % PitchClass::MOD' do
      PitchClass.from_i(-1).should eq(11)
      PitchClass.from_i(12).should eq(0)
      PitchClass.from_i(2).should eq(2)
      PitchClass.from_i(16).should eq(4)      
    end
  end

  it 'should add the #to_pc method to the Fixnum class' do
    5.methods.should include(:to_pc)
  end

  it 'should add the #to_pc method to the Pitch class' do
    Pitch.new.methods.should include(:to_pc)
  end

  it 'should add the #to_pcs method to Enumerable classes, like Array' do
    [1,2,3].methods.should include(:to_pcs)
  end
  
  describe 'Pitch#to_pc' do
    it 'should send semitone through PitchClass.from_i' do
      [ C4, D3, E5, G5,
        Pitch.new(semitone: 4),
        Pitch.new(semitone: 13),
      ].each do |pitch|
        pitch.to_pc.should eq(PitchClass.from_i(pitch.semitone))
      end
    end
  end

  describe 'Fixnum#to_pc' do
    it 'should pass self to PitchClass.from_i' do
      [-1,12,2,16].each do |i|
        i.to_pc.should eq(PitchClass.from_i(i))
      end
    end
  end

  describe '.invert' do
    before :all do
      @cases = {
        C => C,
        Db => B,
        D => Bb,
        Eb => A,
        E => Ab,
        F => G,
        Gb => Gb
      }
    end

    it 'should produce a pitch class' do
      @cases.each do |input_pc, output_pc|
        PitchClass.invert(input_pc).should eq(output_pc)
      end
    end

    it 'should produce a pitch class that when inverted again produces the original pitch class' do
      @cases.each do |input_pc, output_pc|
        PitchClass.invert(output_pc).should eq(input_pc)
      end
    end
  end
end
