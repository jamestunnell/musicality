require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe MeasureScore do
  describe '#initialize' do
    it 'should use empty containers for parameters not given' do
      s = MeasureScore.new(FOUR_FOUR,120)
      s.parts.should be_empty
      s.program.segments.should be_empty
    end
    
    it 'should assign given parameters' do
      m = FOUR_FOUR
      s = MeasureScore.new(m,120)
      s.start_meter.should eq m
      s.start_tempo.should eq 120
      
      parts = { "piano (LH)" => Samples::SAMPLE_PART }
      program = Program.new [0...0.75, 0...0.75]
      mcs = { 1 => Change::Immediate.new(THREE_FOUR) }
      tcs = { 1 => Change::Immediate.new(100) }
      
      s = MeasureScore.new(m,120,
        parts: parts,
        program: program,
        meter_changes: mcs,
        tempo_changes: tcs
      )
      s.parts.should eq parts
      s.program.should eq program
      s.meter_changes.should eq mcs
      s.tempo_changes.should eq tcs
    end
  end
  
  describe '#valid?' do
    {
      'valid start tempo' => [ FOUR_FOUR, 40 ],
      'valid tempo changes' => [ FOUR_FOUR, 30,
        :tempo_changes => { 1 => Change::Gradual.new(40, 2), 2 => Change::Immediate.new(50) } ],
      'valid meter changes' => [ FOUR_FOUR, 120,
        :meter_changes => { 1 => Change::Immediate.new(TWO_FOUR) } ],
      'valid part' => [ FOUR_FOUR, 120, :parts => { "piano" => Samples::SAMPLE_PART }],
      'valid program' => [ FOUR_FOUR, 120, :program => Program.new([0..2,0..2]) ]
    }.each do |context_str,args|
      context context_str do
        it 'should return true' do
          MeasureScore.new(*args).should be_valid
        end
      end
    end
    
    {
      'start tempo object is negative' => [ FOUR_FOUR, -1],
      'start tempo object is zero' => [ FOUR_FOUR, 0],
      'invalid start meter' => [ Meter.new(-1,"1/4".to_r), 120],
      'non-meter start meter' => [ 1, 120],
      'invalid meter in change' => [ FOUR_FOUR, 120,
        :meter_changes => { 1 => Change::Immediate.new(Meter.new(-2,"1/4".to_r)) } ],
      'non-meter values in meter changes' => [ FOUR_FOUR, 120,
        :meter_changes => { 1 => Change::Immediate.new(5) } ],
      'non-immediate meter change' => [ FOUR_FOUR, 120,
        :meter_changes => { 1 => Change::Gradual.new(TWO_FOUR,1) } ],
      'non-integer meter change offset' => [ FOUR_FOUR, 120,
        :meter_changes => { 1.1 => Change::Immediate.new(TWO_FOUR) } ],
      'invalid part' => [ FOUR_FOUR, 120, :parts => { "piano" => Part.new(-0.1) }],
      'invalid program' => [ FOUR_FOUR, 120, :program => Program.new([2..0]) ],
    }.each do |context_str,args|
      context context_str do
        it 'should return false' do
          MeasureScore.new(*args).should be_invalid
        end
      end      
    end
  end
end
