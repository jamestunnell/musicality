require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Score do
  describe '#title' do
    context 'given no arg' do
      it 'should return the title' do
        Score.new(:title => "MyTitle").title.should eq("MyTitle")
      end
    end

    context 'given an arg' do
      it 'should assign the given value to title' do
        score = Score.new(:title => "MyTitle")
        score.title("A Better Title")
        score.title.should eq("A Better Title")
      end
    end
  end

  describe '#composer' do
    context 'given no arg' do
      it 'should return the composer' do
        Score.new(:composer => "Beethoven").composer.should eq("Beethoven")
      end
    end

    context 'given an arg' do
      it 'should assign the given value to composer' do
        score = Score.new(:composer => "Beethoven")
        score.composer("Mozart")
        score.composer.should eq("Mozart")
      end
    end
  end

  describe '#collated?' do
    context 'has program with more than one segment' do
      it 'should return false' do
        score = Score.new(program: [0..2,0..2])
        score.collated?.should be false
      end      
    end
    
    context 'has program with 0 segments' do
      it 'should return false' do
        score = Score.new(program: [])
        score.collated?.should be false        
      end
    end
    
    context 'has program with 1 segment' do
      context 'program segment starts at 0' do
        it 'should return true' do
          score = Score.new(program: [0..2])
          score.collated?.should be true
        end
      end
      
      context 'program segment does not start at 0' do
        it 'should return false' do
          score = Score.new(program: [1..2])
          score.collated?.should be false
        end
      end
    end
  end
    
  describe '#valid?' do
    context 'non-Range objects' do
      it 'should return false' do
        Score.new(program: [1,2,3]).should_not be_valid
      end
    end
    
    context 'increasing, positive segments' do
      it 'should return true' do
        Score.new(program: [0..2,1..2,0..4]).should be_valid
      end
    end
    
    context 'decreasing, positive segments' do
      it 'should return false' do
        Score.new(program: [2..0,2..1,04..0]).should be_invalid
      end
    end

    context 'increasing, negative segments' do
      it 'should return false' do
        Score.new(program: [-1..2,-2..0,-2..2]).should be_invalid
      end
    end
  end
end

describe Score::Tempo do
  before :all do
    @basic_score = Score::Tempo.new(TWO_FOUR, 120,
      meter_changes: {
        2 => Change::Immediate.new(FOUR_FOUR),
        4 => Change::Immediate.new(SIX_EIGHT),
      },
      parts: {
        "abc" => Part.new(Dynamics::MF, notes: "/4 /4 /2 3/4".to_notes),
        "def" => Part.new(Dynamics::MF, notes: "/4 /4 /2 1 /2".to_notes)
      },
      program: [ (0.5)..Rational(1,2), 0..1, 1..2 ]
    )
  end

  describe '#initialize' do
    it 'should use empty containers for parameters not given' do
      s = Score::Tempo.new(FOUR_FOUR,120)
      s.parts.should be_empty
      s.program.should be_empty
    end
    
    it 'should assign given parameters' do
      m = FOUR_FOUR
      s = Score::Tempo.new(m,120)
      s.start_meter.should eq m
      s.start_tempo.should eq 120
      
      parts = { "piano (LH)" => Samples::SAMPLE_PART }
      program = [0...0.75, 0...0.75]
      mcs = { 1 => Change::Immediate.new(THREE_FOUR) }
      tcs = { 1 => Change::Immediate.new(100) }
      
      s = Score::Tempo.new(m,120,
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
  
  describe '#duration' do
    context 'with no parts' do
      it 'should return 0' do
        Score::Tempo.new(TWO_FOUR, 120).duration.should eq(0)
      end
    end
    context 'with one part' do
      it 'should return the duration of the part, in notes' do
        Score::Tempo.new(TWO_FOUR, 120, parts: {
          "abc" => Part.new(Dynamics::MF, notes: "/4 /4 /2 3/4".to_notes)
        }).duration.should eq(1.75)
      end
    end
    
    context 'with two parts' do
      it 'should return the duration of the longest part, in notes' do
        Score::Tempo.new(TWO_FOUR, 120, parts: {
          "abc" => Part.new(Dynamics::MF, notes: "/4 /4 /2 3/4".to_notes),
          "def" => Part.new(Dynamics::MF, notes: "/4 /4 /2 1".to_notes)
        }).duration.should eq(2)
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
      'valid program' => [ FOUR_FOUR, 120, :program => [0..2,0..2] ]
    }.each do |context_str,args|
      context context_str do
        it 'should return true' do
          Score::Tempo.new(*args).should be_valid
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
      'invalid part' => [ FOUR_FOUR, 120, :parts => { "piano" => Part.new(-0.1) }],
      'invalid program' => [ FOUR_FOUR, 120, :program => [2..0] ],
    }.each do |context_str,args|
      context context_str do
        it 'should return false' do
          Score::Tempo.new(*args).should be_invalid
        end
      end      
    end
  end

  describe '#pack' do
    it 'should produce a Hash' do
      @basic_score.pack.should be_a Hash
    end

    it 'should pack program as an array of strings' do
      program = @basic_score.pack[:program]
      program.each {|entry| entry.should be_a String}
    end

    it 'should pack sections as a Hash of strings' do
      program = @basic_score.pack[:sections]
      program.each {|name,entry| entry.should be_a String}
    end
  end

  describe 'unpack' do
    it 'should produce an object equal the original' do
      score2 = Score::Tempo.unpack @basic_score.pack
      score2.should be_a Score
      score2.should eq @basic_score
    end
  end
end

describe Score::Timed do
  describe '#initialize' do
    it 'should use empty containers for parameters not given' do
      s = Score::Timed.new
      s.parts.should be_empty
      s.program.should be_empty
    end
    
    it 'should assign given parameters' do
      parts = { "piano (LH)" => Samples::SAMPLE_PART }
      program = [0...0.75, 0...0.75]
      
      s = Score::Timed.new(parts: parts, program: program)
      s.parts.should eq parts
      s.program.should eq program
    end
  end
  
  describe '#duration' do
    it 'should return the duration of the longest part' do
      Score::Timed.new(parts: {
        "abc" => Part.new(Dynamics::MF, notes: "/4 /4 /2 3/4".to_notes),
        "def" => Part.new(Dynamics::MF, notes: "/4 /4 /2 1".to_notes)
      }).duration.should eq(2)
    end
  end

  describe '#valid?' do
    {
      'valid part' => [ :parts => { "piano" => Samples::SAMPLE_PART }],
      'valid program' => [ :program => [0..2,0..2] ]
    }.each do |context_str,args|
      context context_str do
        it 'should return true' do
          Score::Timed.new(*args).should be_valid
        end
      end
    end
    
    {
      'invalid part' => [ :parts => { "piano" => Part.new(-0.1) }],
      'invalid program' => [ :program => [2..0] ],
    }.each do |context_str,args|
      context context_str do
        it 'should return false' do
          Score::Timed.new(*args).should be_invalid
        end
      end 
    end
  end

  describe '#pack' do
    it 'should produce a Hash' do
      score = Score::Timed.new(parts: {
        "abc" => Part.new(Dynamics::MF, notes: "/4 /4 /2 3/4".to_notes),
        "def" => Part.new(Dynamics::MF, notes: "/4 /4 /2 1".to_notes)
      })
      score.pack.should be_a Hash
    end
  end

  describe 'unpack' do
    it 'should produce an object equal the original' do
      score = Score::Timed.new(parts: {
        "abc" => Part.new(Dynamics::MF, notes: "/4 /4 /2 3/4".to_notes),
        "def" => Part.new(Dynamics::MF, notes: "/4 /4 /2 1".to_notes)
      })
      score2 = Score::Timed.unpack score.pack
      score2.should be_a score.class
      score2.should eq score
    end
  end
end
