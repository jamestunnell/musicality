require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require 'yaml'

describe Meter do
  describe '#initialize' do
    it 'should assign beats per measure and beat duration' do
      [[4,"1/4".to_r],[3,"1/4".to_r],[6,"1/8".to_r]].each do |bpm,bd|
        m = Meter.new(bpm,bd)
        expect(m.beats_per_measure).to eq bpm
        expect(m.beat_duration).to eq bd
      end
    end

    it 'should derive measure duration' do
      {
        [4,"1/4".to_r] => "1/1".to_r,
        [3,"1/4".to_r] => "3/4".to_r,
        [6,"1/8".to_r] => "6/8".to_r,
        [12,"1/8".to_r] => "12/8".to_r,
      }.each do |bpm,bd|
        m = Meter.new(bpm,bd)
        expect(m.measure_duration).to eq(bpm*bd)
      end
    end
  end

  describe '#==' do
    context 'meters with same beat duration and beats per measure' do
      it 'should return true' do
        m1 = Meter.new(4,"1/4".to_r)
        m2 = Meter.new(4,"1/4".to_r)
        expect(m1).to eq m2
      end
    end

    context 'meters with same meausre duration but different beat duration' do
      it 'should return false' do
        m1 = Meter.new(4,"1/4".to_r)
        m2 = Meter.new(2,"1/2".to_r)
        expect(m1).to_not eq m2
      end
    end
  end

  describe '#to_yaml' do
    it 'should produce YAML that can be loaded' do
      m = Meter.new(4,"1/4".to_r)
      expect(YAML.load(m.to_yaml)).to eq m
    end
  end

  describe '#pack' do
    it 'should produce a Hash' do
      expect(FOUR_FOUR.pack).to be_a Hash
    end
  end

  describe 'unpack' do
    it 'should produce an object equal the original' do
      m2 = Meter.unpack FOUR_FOUR.pack
      expect(m2).to be_a Meter
      expect(m2).to eq(FOUR_FOUR)
    end
  end

  describe '#to_s' do
    context 'beat duration with 1 in denominator' do
      it 'should return string of fraction: beats_per_measure / beat_duration.denom' do
        expect(FOUR_FOUR.to_s).to eq("4/4")
        expect(TWO_FOUR.to_s).to eq("2/4")
        expect(THREE_FOUR.to_s).to eq("3/4")
        expect(TWO_TWO.to_s).to eq("2/2")
      end
    end

    context 'beat duration with >1 in denominator' do
      it 'should return beats_per_measure * beat_dur fraction' do
        expect(SIX_EIGHT.to_s).to eq("2*3/8")
        expect(Meter.new(3,"3/8".to_r).to_s).to eq("3*3/8")
      end
    end
  end

  describe '#valid?' do
    {
      '4/4 meter' => [4,'1/4'.to_r],
      '2/4 meter' => [2,'1/4'.to_r],
      '3/4 meter' => [2,'1/4'.to_r],
      '6/8 meter' => [6,'1/8'.to_r],
      '12/8 meter' => [12,'1/8'.to_r],
    }.each do |context_str,args|
      context context_str do
        it 'should return true' do
          expect(Meter.new(*args)).to be_valid
        end
      end
    end

    {
      'non-integer positive beats per measure' => [4.0,"1/4".to_r],
      'integer negative beats per measure' => [-1,"1/4".to_r],
      'zero beat duration' => [4,0.to_r],
      'negative beat duration' => [4,-1.to_r],
    }.each do |context_str,args|
      context context_str do
        it 'should return false' do
          expect(Meter.new(*args)).to be_invalid
        end
      end
    end
  end
end
