require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Score do
  describe '#collated?' do
    context 'has program with more than one segment' do
      it 'should return false' do
        score = Score.new(program: Program.new([0..2,0..2]))
        score.collated?.should be false
      end      
    end
    
    context 'has program with 0 segments' do
      it 'should return false' do
        score = Score.new(program: Program.new([]))
        score.collated?.should be false        
      end
    end
    
    context 'has program with 1 segment' do
      context 'program segment starts at 0' do
        it 'should return true' do
          score = Score.new(program: Program.new([0..2]))
          score.collated?.should be true
        end
      end
      
      context 'program segment does not start at 0' do
        it 'should return false' do
          score = Score.new(program: Program.new([1..2]))
          score.collated?.should be false
        end
      end
    end
  end
  
  describe '#duration' do
    context 'no parts' do
      it 'should return 0' do
        Score.new.duration.should eq(0)
      end
    end
    
    context 'one part' do
      it 'should return the part duration' do
        Score.new(parts: {"part1" => Part.new(Dynamics::PP,
          notes: "/4 /4 /2 1".to_notes)
        }).duration.should eq(2)
      end
    end
  end
end

describe Score::Measured do
  describe '#initialize' do
    it 'should use empty containers for parameters not given' do
      s = Score::Measured.new(FOUR_FOUR,120)
      s.parts.should be_empty
      s.program.segments.should be_empty
    end
    
    it 'should assign given parameters' do
      m = FOUR_FOUR
      s = Score::Measured.new(m,120)
      s.start_meter.should eq m
      s.start_tempo.should eq 120
      
      parts = { "piano (LH)" => Samples::SAMPLE_PART }
      program = Program.new [0...0.75, 0...0.75]
      mcs = { 1 => Change::Immediate.new(THREE_FOUR) }
      tcs = { 1 => Change::Immediate.new(100) }
      
      s = Score::Measured.new(m,120,
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
  
  describe '#measures_long' do
    context 'with no meter changes' do
      context 'with no parts' do
        it 'should return 0' do
          Score::Measured.new(TWO_FOUR, 120).measures_long.should eq(0)
        end
      end

      context 'with one part' do
        it 'should return the duration of the part, in measures' do
          Score::Measured.new(TWO_FOUR, 120, parts: {
            "abc" => Part.new(Dynamics::MF, notes: "/4 /4 /2 3/4".to_notes)
          }).measures_long.should eq(3.5)
        end
      end
      
      context 'with two parts' do
        it 'should return the duration of the longest part, in measures' do
          Score::Measured.new(TWO_FOUR, 120, parts: {
            "abc" => Part.new(Dynamics::MF, notes: "/4 /4 /2 3/4".to_notes),
            "def" => Part.new(Dynamics::MF, notes: "/4 /4 /2 1".to_notes)
          }).measures_long.should eq(4)
        end
      end
    end
    
    context 'with meter changes' do
      it 'should return the duration of the longest part, in measures' do
        Score::Measured.new(TWO_FOUR, 120,
          meter_changes: {
            2 => Change::Immediate.new(FOUR_FOUR),
          },
          parts: {
            "abc" => Part.new(Dynamics::MF, notes: "/4 /4 /2 3/4".to_notes),
            "def" => Part.new(Dynamics::MF, notes: "/4 /4 /2 1".to_notes)
          }
        ).measures_long.should eq(3)
        
        Score::Measured.new(TWO_FOUR, 120,
          meter_changes: {
            2 => Change::Immediate.new(FOUR_FOUR),
            4 => Change::Immediate.new(SIX_EIGHT),
          },
          parts: {
            "abc" => Part.new(Dynamics::MF, notes: "/4 /4 /2 3/4".to_notes),
            "def" => Part.new(Dynamics::MF, notes: "/4 /4 /2 1 /2".to_notes)
          }
        ).measures_long.should eq(3.5)
      end
    end
    
    context 'given specific note duration' do
      it 'should change the given note duration to measures' do
        score = Score::Measured.new(TWO_FOUR, 120,
            meter_changes: {
              2 => Change::Immediate.new(FOUR_FOUR),
              4 => Change::Immediate.new(SIX_EIGHT)
        })
        
        { 1 => 2, 1.5 => 2.5, 2 => 3, 3 => 4, 3.75 => 5
        }.each do |note_dur, meas_dur|
          score.measures_long(note_dur).should eq(meas_dur)
        end
      end
    end
  end

  describe '#valid?' do
    {
      'valid start tempo' => [ FOUR_FOUR, 40 ],
      'valid tempo changes' => [ FOUR_FOUR, 30,
        :tempo_changes => { 1 => Change::Gradual.linear(40, 2), 2 => Change::Immediate.new(50) } ],
      'valid meter changes' => [ FOUR_FOUR, 120,
        :meter_changes => { 1 => Change::Immediate.new(TWO_FOUR) } ],
      'valid part' => [ FOUR_FOUR, 120, :parts => { "piano" => Samples::SAMPLE_PART }],
      'valid program' => [ FOUR_FOUR, 120, :program => Program.new([0..2,0..2]) ]
    }.each do |context_str,args|
      context context_str do
        it 'should return true' do
          Score::Measured.new(*args).should be_valid
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
        :meter_changes => { 1 => Change::Gradual.linear(TWO_FOUR,1) } ],
      'non-integer meter change offset' => [ FOUR_FOUR, 120,
        :meter_changes => { 1.1 => Change::Immediate.new(TWO_FOUR) } ],
      'invalid part' => [ FOUR_FOUR, 120, :parts => { "piano" => Part.new(-0.1) }],
      'invalid program' => [ FOUR_FOUR, 120, :program => Program.new([2..0]) ],
    }.each do |context_str,args|
      context context_str do
        it 'should return false' do
          Score::Measured.new(*args).should be_invalid
        end
      end      
    end
  end
end

describe Score::Unmeasured do
  describe '#initialize' do
    it 'should use empty containers for parameters not given' do
      s = Score::Unmeasured.new(30)
      s.parts.should be_empty
      s.program.segments.should be_empty
    end
    
    it 'should assign given parameters' do
      s = Score::Unmeasured.new(30)
      s.start_tempo.should eq(30)
      
      parts = { "piano (LH)" => Samples::SAMPLE_PART }
      program = Program.new [0...0.75, 0...0.75]
      tcs = { 1 => Change::Immediate.new(40) }
      
      s = Score::Unmeasured.new(30,
        parts: parts,
        program: program,
        tempo_changes: tcs
      )
      s.parts.should eq parts
      s.program.should eq program
      s.tempo_changes.should eq tcs
    end
  end

  describe '#notes_long' do
    it 'should return the duration of the longest part' do
      Score::Unmeasured.new(120, parts: {
        "abc" => Part.new(Dynamics::MF, notes: "/4 /4 /2 3/4".to_notes),
        "def" => Part.new(Dynamics::MF, notes: "/4 /4 /2 1".to_notes)
      }).notes_long.should eq(2)
    end
  end
  
  describe '#valid?' do
    {
      'valid start tempo' => [ 40 ],
      'valid tempo changes' => [ 30,
        :tempo_changes => { 1 => Change::Gradual.linear(40, 2), 2 => Change::Immediate.new(50) } ],
      'valid part' => [ 30, :parts => { "piano" => Samples::SAMPLE_PART }],
      'valid program' => [ 30, :program => Program.new([0..2,0..2]) ]
    }.each do |context_str,args|
      context context_str do
        it 'should return true' do
          Score::Unmeasured.new(*args).should be_valid
        end
      end
    end
    
    {
      'start tempo valid is zero' => [ 0 ],
      'start tempo valid is negative' => [ -1 ],
      'tempo change value is not a valid value' => [ 30,
        :tempo_changes => { 1 => Change::Gradual.linear(-1,1) } ],
      'invalid part' => [ 30, :parts => { "piano" => Part.new(-0.1) }],
      'invalid program' => [ 30, :program => Program.new([2..0]) ],
    }.each do |context_str,args|
      context context_str do
        it 'should return false' do
          Score::Unmeasured.new(*args).should be_invalid
        end
      end 
    end
  end
end

describe Score::Timed do
  describe '#initialize' do
    it 'should use empty containers for parameters not given' do
      s = Score::Timed.new
      s.parts.should be_empty
      s.program.segments.should be_empty
    end
    
    it 'should assign given parameters' do
      parts = { "piano (LH)" => Samples::SAMPLE_PART }
      program = Program.new [0...0.75, 0...0.75]
      
      s = Score::Timed.new(parts: parts, program: program)
      s.parts.should eq parts
      s.program.should eq program
    end
  end
  
  describe '#seconds_long' do
    it 'should return the duration of the longest part' do
      Score::Timed.new(parts: {
        "abc" => Part.new(Dynamics::MF, notes: "/4 /4 /2 3/4".to_notes),
        "def" => Part.new(Dynamics::MF, notes: "/4 /4 /2 1".to_notes)
      }).seconds_long.should eq(2)
    end
  end

  describe '#valid?' do
    {
      'valid part' => [ :parts => { "piano" => Samples::SAMPLE_PART }],
      'valid program' => [ :program => Program.new([0..2,0..2]) ]
    }.each do |context_str,args|
      context context_str do
        it 'should return true' do
          Score::Timed.new(*args).should be_valid
        end
      end
    end
    
    {
      'invalid part' => [ :parts => { "piano" => Part.new(-0.1) }],
      'invalid program' => [ :program => Program.new([2..0]) ],
    }.each do |context_str,args|
      context context_str do
        it 'should return false' do
          Score::Timed.new(*args).should be_invalid
        end
      end 
    end
  end
end
