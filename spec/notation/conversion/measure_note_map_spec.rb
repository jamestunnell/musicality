require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe 'Conversion.measure_note_map' do
  before :all do
    mdurs = Hash[ [[0, (3/4)], [1, (1/2)], [3, (3/4)]] ]
    @moffs = [ 0, 1, 3, 4, 5, 6, 7, 8, 11, 14, 17, 20, (45/2)]
    @mnoff_map = Conversion.measure_note_map(@moffs,mdurs)
  end
  
  it 'should return a Hash' do
    @mnoff_map.should be_a Hash
  end
  
  it 'should have same size as array returned by #measure_offsets' do
    @mnoff_map.size.should eq(@moffs.size)
  end
  
  it 'should have a key for each offset in the array returned by #measure_offsets' do
    @mnoff_map.keys.sort.should eq(@moffs)
  end
  
  context 'single measure duration at 0' do
    it 'should mutiply all measure offsets by start measure duration' do
      [TWO_FOUR,SIX_EIGHT,FOUR_FOUR,THREE_FOUR].each do |meter|
        mdur = meter.measure_duration
        mdurs = { 0 => mdur }
        tgt = @moffs.map {|moff| moff * mdur}
        Conversion.measure_note_map(@moffs,mdurs).values.sort.should eq(tgt)
      end
    end
  end
  
  context '1 meter change' do
    before :all do
      @first_mc_off = 3
      @start_meter = THREE_FOUR
      @new_meter = TWO_FOUR
      @score = MeasureScore.new(@start_meter, Tempo::BPM.new(120),
        meter_changes: { @first_mc_off => Change::Immediate.new(@new_meter) },
        tempo_changes: {
          "1/2".to_r => Change::Gradual.new(Tempo::BPM.new(100),1),
          2 => Change::Immediate.new(Tempo::BPM.new(120)),
          3 => Change::Immediate.new(Tempo::BPM.new(100)),
          3.1 => Change::Gradual.new(Tempo::BPM.new(100),1),
          5 => Change::Immediate.new(Tempo::BPM.new(120)),
          6 => Change::Immediate.new(Tempo::BPM.new(100)),
        }
      )
      @moffs = @score.measure_offsets
      @mdurs = @score.measure_durations
      @mnoff_map = Conversion.measure_note_map(@moffs,@mdurs)
    end
    
    it 'should mutiply all measure offsets that occur on or before 1st meter change offset by start measure duration' do
      moffs = @moffs.select{ |x| x <= @first_mc_off }
      tgt = moffs.map do |moff|
        moff * @start_meter.measure_duration
      end.sort
      src = @mnoff_map.select {|k,v| k <= @first_mc_off }
      src.values.sort.should eq(tgt)
    end
    
    it 'should, for any measure offsets occurring after 1st meter change offset, add 1st_meter_change_offset * 1st_measure_duration to \
        new_measure_duration * (offset - 1st_meter_change_offset)' do
      moffs = @moffs.select{ |x| x > @first_mc_off }
      tgt = moffs.map do |moff|
        @first_mc_off * @start_meter.measure_duration + (moff - @first_mc_off) * @new_meter.measure_duration
      end.sort
      src = @mnoff_map.select {|k,v| k > @first_mc_off }
      src.values.sort.should eq(tgt)
    end
  end
end
