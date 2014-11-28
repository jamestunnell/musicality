require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe ScoreConverter::TempoBased do
  
end

describe ScoreConverter::Measured do
  describe '#initialize' do
    context 'current score is invalid' do
      it 'should raise NotValidError' do
        score = Score::Measured.new(1, 120)
        expect { ScoreConverter::Measured.new(score,200) }.to raise_error(NotValidError)
      end
    end    
  end
  
  describe '#convert_parts' do
    before :each do
      @changeA = Change::Immediate.new(Dynamics::PP)
      @changeB = Change::Gradual.linear(Dynamics::F, 2)
      @score = Score::Measured.new(FOUR_FOUR, 120,
        parts: {"simple" => Part.new(Dynamics::MP, dynamic_changes: { 1 => @changeA, 3 => @changeB })}
      )
    end
    
    it 'should return Hash with original part names' do
      parts = ScoreConverter::Measured.new(@score,200).convert_parts
      parts.should be_a Hash
      parts.keys.sort.should eq(@score.parts.keys.sort)
    end
    
    it 'should convert part dynamic change offsets from measure-based to note-based' do
      parts = ScoreConverter::Measured.new(@score,200).convert_parts
      parts.should have_key("simple")
      part = parts["simple"]
      part.dynamic_changes.keys.sort.should eq([2,6])
      change = part.dynamic_changes[2.0]
      change.end_value.should eq(@changeA.end_value)
      change = part.dynamic_changes[6.0]
      change.end_value.should eq(@changeB.end_value)
      change.duration.should eq(4)
      
      #@score.start_meter = THREE_FOUR
      #parts = ScoreConverter::Measured.new(@score,200).convert_parts
      #parts.should have_key("simple")
      #part = parts["simple"]
      #part.dynamic_changes.keys.sort.should eq([Rational(3,4),Rational(9,4)])
      #change = part.dynamic_changes[Rational(3,4)]
      #change.end_value.should eq(@changeA.end_value)
      #change.duration.should eq(0)
      #change = part.dynamic_changes[Rational(9,4)]
      #change.end_value.should eq(@changeB.end_value)
      #change.duration.should eq(1.5)
    end
    
    #context 'gradual changes with positive elapsed and/or remaining' do
    #  it 'should change elapsed and remaining so they reflect note-based offsets' do
    #    score = Score::Measured.new(THREE_FOUR,120, parts: {
    #      "abc" => Part.new(Dynamics::P, dynamic_changes: {
    #          2 => Change::Gradual.linear(Dynamics::F,2,1,3),
    #          7 => Change::Gradual.linear(Dynamics::F,1,4,5)
    #      })
    #    })
    #    converter = ScoreConverter::Measured.new(score)
    #    parts = converter.convert_parts
    #    dcs = parts["abc"].dynamic_changes
    #    
    #    dcs.keys.should eq([Rational(6,4), Rational(21,4)])
    #    dcs[Rational(3,2)].should eq(Change::Gradual.linear(Dynamics::F,Rational(6,4),Rational(3,4),Rational(9,4)))
    #    dcs[Rational(21,4)].should eq(Change::Gradual.linear(Dynamics::F,Rational(3,4),Rational(12,4),Rational(15,4)))
    #  end
    #end
  end
  
  describe '#convert_program' do
    before :each do
      @prog = Program.new([0...4,2...5])
      @score = Score::Measured.new(FOUR_FOUR, 120, program: @prog)
      @converter = ScoreConverter::Measured.new(@score,200)
    end
    
    it 'shuld return Program with same number of segments' do
      prog = @converter.convert_program
      prog.should be_a Program
      prog.segments.size.should eq(@score.program.segments.size)
    end
  
    it 'should convert program segments offsets from measure-based to note-based' do
      prog = ScoreConverter::Measured.new(@score,200).convert_program
      prog.segments.size.should eq(2)
      prog.segments[0].first.should eq(0)
      prog.segments[0].last.should eq(8)
      prog.segments[1].first.should eq(4)
      prog.segments[1].last.should eq(10)
      
      @score.start_meter = THREE_FOUR
      prog = ScoreConverter::Measured.new(@score,200).convert_program
      prog.segments.size.should eq(2)
      prog.segments[0].first.should eq(0)
      prog.segments[0].last.should eq(6)
      prog.segments[1].first.should eq(3)
      prog.segments[1].last.should eq(7.5)
    end
  end
  
  describe '#convert_score' do    
    it 'should return a timed score' do
      score = Score::Measured.new(FOUR_FOUR, 120)
      converter = ScoreConverter::Measured.new(score,200)
      converter.convert_score.should be_a Score::Timed
    end
  
    it 'should use output from convert_program' do
      prog = Program.new([0...4,2...5])
      score = Score::Measured.new(FOUR_FOUR, 120, program: prog)
      converter = ScoreConverter::Measured.new(score,200)
      nscore = converter.convert_score
      nscore.program.should eq(converter.convert_program)
    end
    
    it 'should use output from convert_parts' do
      changeA = Change::Immediate.new(Dynamics::PP)
      changeB = Change::Gradual.linear(Dynamics::F, 2)
      score = Score::Measured.new(FOUR_FOUR, 120,
        parts: {"simple" => Part.new(Dynamics::MP, dynamic_changes: { 1 => changeA, 3 => changeB })}
      )
      converter = ScoreConverter::Measured.new(score,200)
      nscore = converter.convert_score
      nscore.parts.should eq(converter.convert_parts)
    end
  end  
end

describe ScoreConverter::Unmeasured do
  describe '#initialize' do
    context 'current score is invalid' do
      it 'should raise NotValidError' do
        score = Score::Unmeasured.new(-1)
        expect { ScoreConverter::Unmeasured.new(score,200) }.to raise_error(NotValidError)
      end
    end
  end
  
  describe '#convert_parts' do
    before :each do
      @changeA = Change::Immediate.new(Dynamics::PP)
      @changeB = Change::Gradual.linear(Dynamics::F, 2)
      @score = Score::Unmeasured.new(120,
        parts: {
          "normal" => Part.new(Dynamics::MP,
            dynamic_changes: { 1 => @changeA, 3 => @changeB },
            notes: "/4C2 /8D2 /8E2 /2C2".to_notes * 4),
          "empty" => Part.new(Dynamics::PP)
        }
      )
      @parts = ScoreConverter::Unmeasured.new(@score,200).convert_parts
    end
    
    it 'should return Hash with original part names' do
      @parts.should be_a Hash
      @parts.keys.sort.should eq(@score.parts.keys.sort)
    end
    
    it 'should convert part dynamic change offsets from note-based to time-based' do
      part = @parts["normal"]
      part.dynamic_changes.keys.sort.should eq([2,6])
      change = part.dynamic_changes[2.0]
      change.end_value.should eq(@changeA.end_value)
      change = part.dynamic_changes[6.0]
      change.end_value.should eq(@changeB.end_value)
      change.duration.should eq(4.0)
    end
    
    it 'should convert note durations to time durations' do
      part = @parts["normal"]
      part.notes.map {|x| x.duration }.should eq([0.5,0.25,0.25,1]*4)
    end
    
    context 'trimmed, gradual changes' do
      it 'should change preceding and remaining so they reflect time-based duration' do
        score = Score::Unmeasured.new(120, parts: {
          "abc" => Part.new(Dynamics::P, dynamic_changes: {
              2 => Change::Gradual.linear(Dynamics::F,4).to_trimmed(2,1),
              7 => Change::Gradual.linear(Dynamics::F,5).to_trimmed(1,3)
          })
        })
        converter = ScoreConverter::Unmeasured.new(score,200)
        parts = converter.convert_parts
        dcs = parts["abc"].dynamic_changes
        
        dcs.keys.should eq([4,14])
        dcs[4.0].should eq(Change::Gradual.linear(Dynamics::F,8).to_trimmed(4,2))
        dcs[14.0].should eq(Change::Gradual.linear(Dynamics::F,10).to_trimmed(2,6))
      end
    end
  end
  
  describe '#convert_program' do
    before :each do
      @prog = Program.new([0...4,2...5])
      @score = Score::Unmeasured.new(120, program: @prog)
      @converter = ScoreConverter::Unmeasured.new(@score,200)
      @prog2 = @converter.convert_program
    end
    
    it 'should return Program with same number of segments' do
      @prog2.should be_a Program
      @prog2.segments.size.should eq(@prog.segments.size)
    end
  
    it 'should convert program segments offsets from note-based to time-based' do
      prog = @prog2
      prog.segments[0].first.should eq(0)
      prog.segments[0].last.should eq(8)
      prog.segments[1].first.should eq(4)
      prog.segments[1].last.should eq(10)
    end
  end
  
  describe '#convert_score' do    
    it 'should return an timed score' do
      score = Score::Unmeasured.new(120)
      converter = ScoreConverter::Unmeasured.new(score,200)
      converter.convert_score.should be_a Score::Timed
    end
  
    it 'should use output from convert_program' do
      prog = Program.new([0...4,2...5])
      score = Score::Unmeasured.new(120, program: prog)
      converter = ScoreConverter::Unmeasured.new(score,200)
      nscore = converter.convert_score
      nscore.program.should eq(converter.convert_program)
    end
    
    it 'should use output from convert_parts' do
      changeA = Change::Immediate.new(Dynamics::PP)
      changeB = Change::Gradual.linear(Dynamics::F, 2)
      score = Score::Unmeasured.new(120,
        parts: {"simple" => Part.new(Dynamics::MP, dynamic_changes: { 1 => changeA, 3 => changeB })}
      )
      converter = ScoreConverter::Unmeasured.new(score,200)
      nscore = converter.convert_score
      nscore.parts.should eq(converter.convert_parts)
    end
  end
end
