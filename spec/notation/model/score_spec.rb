require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Score do
  describe '#title' do
    context 'given no arg' do
      it 'should return the title' do
        expect(Score.new(:title => "MyTitle").title).to eq("MyTitle")
      end
    end

    context 'given an arg' do
      it 'should assign the given value to title' do
        score = Score.new(:title => "MyTitle")
        score.title("A Better Title")
        expect(score.title).to eq("A Better Title")
      end
    end
  end

  describe '#composer' do
    context 'given no arg' do
      it 'should return the composer' do
        expect(Score.new(:composer => "Beethoven").composer).to eq("Beethoven")
      end
    end

    context 'given an arg' do
      it 'should assign the given value to composer' do
        score = Score.new(:composer => "Beethoven")
        score.composer("Mozart")
        expect(score.composer).to eq("Mozart")
      end
    end
  end

  describe '#collated?' do
    context 'has program with more than one segment' do
      it 'should return false' do
        score = Score.new(program: [0..2,0..2])
        expect(score.collated?).to be false
      end
    end

    context 'has program with 0 segments' do
      it 'should return false' do
        score = Score.new(program: [])
        expect(score.collated?).to be false
      end
    end

    context 'has program with 1 segment' do
      context 'program segment starts at 0' do
        context 'program segment ends at score duration' do
          it 'should return true' do
            score = Score.new(program: [0..2],
              parts: { "dummy" => Part.new(Dynamics::MP, notes: [Note.whole]*2)}
            )
            expect(score.collated?).to be true
          end
        end

        context 'program segment does not end at score duration' do
          it 'should return false' do
            score = Score.new(program: [0..1],
              parts: { "dummy" => Part.new(Dynamics::MP, notes: [Note.whole]*2) }
            )
            expect(score.collated?).to be false
            score.program = [0..3]
            expect(score.collated?).to be false
          end
        end
      end

      context 'program segment does not start at 0' do
        it 'should return false' do
          score = Score.new(program: [1..2])
          expect(score.collated?).to be false
        end
      end
    end
  end

  describe '#valid?' do
    context 'non-Range objects' do
      it 'should return false' do
        expect(Score.new(program: [1,2,3])).to_not be_valid
      end
    end

    context 'increasing, positive segments' do
      it 'should return true' do
        expect(Score.new(program: [0..2,1..2,0..4])).to be_valid
      end
    end

    context 'decreasing, positive segments' do
      it 'should return false' do
        expect(Score.new(program: [2..0,2..1,04..0])).to be_invalid
      end
    end

    context 'increasing, negative segments' do
      it 'should return false' do
        expect(Score.new(program: [-1..2,-2..0,-2..2])).to be_invalid
      end
    end
  end
end

describe Score::Tempo do
  before :all do
    @basic_score = Score::Tempo.new(120,
      start_meter: TWO_FOUR,
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
      s = Score::Tempo.new(120)
      expect(s.parts).to be_empty
      expect(s.program).to be_empty
      expect(s.tempo_changes).to be_empty
      expect(s.meter_changes).to be_empty
    end

    it 'should assign given parameters' do
      s = Score::Tempo.new(120)
      expect(s.start_tempo).to eq 120

      m = FOUR_FOUR
      parts = { "piano (LH)" => Samples::SAMPLE_PART }
      program = [0...0.75, 0...0.75]
      mcs = { 1 => Change::Immediate.new(THREE_FOUR) }
      tcs = { 1 => Change::Immediate.new(100) }

      s = Score::Tempo.new(120,
        start_meter: m,
        parts: parts,
        program: program,
        meter_changes: mcs,
        tempo_changes: tcs
      )
      expect(s.start_meter).to eq m
      expect(s.parts).to eq parts
      expect(s.program).to eq program
      expect(s.meter_changes).to eq mcs
      expect(s.tempo_changes).to eq tcs
    end
  end

  describe '#duration' do
    context 'with no parts' do
      it 'should return 0' do
        expect(Score::Tempo.new(120).duration).to eq(0)
      end
    end
    context 'with one part' do
      it 'should return the duration of the part, in notes' do
        s = Score::Tempo.new(120, parts: {
          "abc" => Part.new(Dynamics::MF, notes: "/4 /4 /2 3/4".to_notes)
        })
        expect(s.duration).to eq(1.75)
      end
    end

    context 'with two parts' do
      it 'should return the duration of the longest part, in notes' do
        s = Score::Tempo.new(120, parts: {
          "abc" => Part.new(Dynamics::MF, notes: "/4 /4 /2 3/4".to_notes),
          "def" => Part.new(Dynamics::MF, notes: "/4 /4 /2 1".to_notes)
        })
        expect(s.duration).to eq(2)
      end
    end
  end

  describe '#valid?' do
    {
      'valid start tempo' => [ 40 ],
      'valid tempo changes' => [ 30,
        :tempo_changes => { 1 => Change::Gradual.linear(40, 2), 2 => Change::Immediate.new(50) } ],
      'valid start meter' => [80, :start_meter => FOUR_FOUR ],
      'valid meter changes' => [ 120,
        :meter_changes => { 1 => Change::Immediate.new(TWO_FOUR) } ],
      'valid part' => [ 120, :parts => { "piano" => Samples::SAMPLE_PART }],
      'valid program' => [ 120, :program => [0..2,0..2] ]
    }.each do |context_str,args|
      context context_str do
        it 'should return true' do
          expect(Score::Tempo.new(*args)).to be_valid
        end
      end
    end

    {
      'start tempo object is negative' => [ -1],
      'start tempo object is zero' => [ 0],
      'invalid start meter' => [ 120, :start_meter => Meter.new(-1,"1/4".to_r) ],
      'non-meter start meter' => [ 120, :start_meter => 1 ],
      'invalid meter in change' => [ 120,
        :meter_changes => { 1 => Change::Immediate.new(Meter.new(-2,"1/4".to_r)) } ],
      'non-meter values in meter changes' => [ 120,
        :meter_changes => { 1 => Change::Immediate.new(5) } ],
      'non-immediate meter change' => [ 120,
        :meter_changes => { 1 => Change::Gradual.linear(TWO_FOUR,1) } ],
      'invalid part' => [ 120, :parts => { "piano" => Part.new(-0.1) }],
      'invalid program' => [ 120, :program => [2..0] ],
    }.each do |context_str,args|
      context context_str do
        it 'should return false' do
          expect(Score::Tempo.new(*args)).to be_invalid
        end
      end
    end
  end

  describe '#pack' do
    it 'should produce a Hash' do
      expect(@basic_score.pack).to be_a Hash
    end

    it 'should pack program as an array of strings' do
      program = @basic_score.pack[:program]
      program.each {|entry| expect(entry).to be_a String}
    end

    it 'should pack sections as a Hash of strings' do
      program = @basic_score.pack[:sections]
      program.each {|name,entry| expect(entry).to be_a String}
    end
  end

  describe 'unpack' do
    it 'should produce an object equal the original' do
      score2 = Score::Tempo.unpack @basic_score.pack
      expect(score2).to be_a Score
      expect(score2).to eq @basic_score
    end
  end
end

describe Score::Timed do
  describe '#initialize' do
    it 'should use empty containers for parameters not given' do
      s = Score::Timed.new
      expect(s.parts).to be_empty
      expect(s.program).to be_empty
    end

    it 'should assign given parameters' do
      parts = { "piano (LH)" => Samples::SAMPLE_PART }
      program = [0...0.75, 0...0.75]

      s = Score::Timed.new(parts: parts, program: program)
      expect(s.parts).to eq parts
      expect(s.program).to eq program
    end
  end

  describe '#duration' do
    it 'should return the duration of the longest part' do
      s = Score::Timed.new(parts: {
        "abc" => Part.new(Dynamics::MF, notes: "/4 /4 /2 3/4".to_notes),
        "def" => Part.new(Dynamics::MF, notes: "/4 /4 /2 1".to_notes)
      })
      expect(s.duration).to eq(2)
    end
  end

  describe '#valid?' do
    {
      'valid part' => [ :parts => { "piano" => Samples::SAMPLE_PART }],
      'valid program' => [ :program => [0..2,0..2] ]
    }.each do |context_str,args|
      context context_str do
        it 'should return true' do
          expect(Score::Timed.new(*args)).to be_valid
        end
      end
    end

    {
      'invalid part' => [ :parts => { "piano" => Part.new(-0.1) }],
      'invalid program' => [ :program => [2..0] ],
    }.each do |context_str,args|
      context context_str do
        it 'should return false' do
          expect(Score::Timed.new(*args)).to be_invalid
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
      expect(score.pack).to be_a Hash
    end
  end

  describe 'unpack' do
    it 'should produce an object equal the original' do
      score = Score::Timed.new(parts: {
        "abc" => Part.new(Dynamics::MF, notes: "/4 /4 /2 3/4".to_notes),
        "def" => Part.new(Dynamics::MF, notes: "/4 /4 /2 1".to_notes)
      })
      score2 = Score::Timed.unpack score.pack
      expect(score2).to be_a score.class
      expect(score2).to eq score
    end
  end
end
