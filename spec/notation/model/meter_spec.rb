require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Meter do
  describe '#initialize' do
    it 'should assign beats per measure and beat duration' do
      [[4,"1/4".to_r],[3,"1/4".to_r],[6,"1/8".to_r]].each do |bpm,bd|
        m = Meter.new(bpm,bd)
        m.beats_per_measure.should eq bpm
        m.beat_duration.should eq bd
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
        m.measure_duration.should eq(bpm*bd)
      end      
    end
  end
  
  describe '#==' do
    context 'meters with same beat duration and beats per measure' do
      it 'should return true' do
        m1 = Meter.new(4,"1/4".to_r)
        m2 = Meter.new(4,"1/4".to_r)
        m1.should eq m2
      end
    end
    
    context 'meters with same meausre duration but different beat duration' do
      it 'should return false' do
        m1 = Meter.new(4,"1/4".to_r)
        m2 = Meter.new(2,"1/2".to_r)
        m1.should_not eq m2
      end
    end
  end
  
  describe '#to_yaml' do
    it 'should produce YAML that can be loaded' do
      m = Meter.new(4,"1/4".to_r)
      YAML.load(m.to_yaml).should eq m
    end
  end
  
  describe '#to_s' do
    context 'beat duration with 1 in denominator' do
      it 'should return string of fraction: beats_per_measure / beat_duration.denom' do
        FOUR_FOUR.to_s.should eq("4/4")
        TWO_FOUR.to_s.should eq("2/4")
        THREE_FOUR.to_s.should eq("3/4")
        TWO_TWO.to_s.should eq("2/2")
      end
    end
    
    context 'beat duration with >1 in denominator' do
      it 'should return beats_per_measure * beat_dur fraction' do
        SIX_EIGHT.to_s.should eq("2*3/8")
        Meter.new(3,"3/8".to_r).to_s.should eq("3*3/8")
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
          Meter.new(*args).should be_valid
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
          Meter.new(*args).should be_invalid
        end
      end      
    end
  end
end
