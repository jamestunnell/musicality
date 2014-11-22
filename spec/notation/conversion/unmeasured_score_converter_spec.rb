require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe UnmeasuredScoreConverter do
  describe '#initialize' do
    context 'current score is invalid' do
      it 'should raise NotValidError' do
        score = Score::Unmeasured.new(-1)
        expect { UnmeasuredScoreConverter.new(score,200) }.to raise_error(NotValidError)
      end
    end
  end
  
  describe '#convert_parts' do
    before :each do
      @changeA = Change::Immediate.new(Dynamics::PP)
      @changeB = Change::Gradual.new(Dynamics::F, 2)
      @score = Score::Unmeasured.new(120,
        parts: {
          "normal" => Part.new(Dynamics::MP,
            dynamic_changes: { 1 => @changeA, 3 => @changeB },
            notes: "/4C2 /8D2 /8E2 /2C2".to_notes * 4),
          "empty" => Part.new(Dynamics::PP)
        }
      )
      @parts = UnmeasuredScoreConverter.new(@score,200).convert_parts
    end
    
    it 'should return Hash with original part names' do
      @parts.should be_a Hash
      @parts.keys.sort.should eq(@score.parts.keys.sort)
    end
    
    it 'should convert part dynamic change offsets from note-based to time-based' do
      part = @parts["normal"]
      part.dynamic_changes.keys.sort.should eq([2,6])
      change = part.dynamic_changes[2.0]
      change.value.should eq(@changeA.value)
      change.duration.should eq(0)
      change = part.dynamic_changes[6.0]
      change.value.should eq(@changeB.value)
      change.duration.should eq(4.0)
    end
    
    it 'should convert note durations to time durations' do
      part = @parts["normal"]
      part.notes.map {|x| x.duration }.should eq([0.5,0.25,0.25,1]*4)
    end
    
    context 'gradual changes with positive elapsed and/or remaining' do
      it 'should change elapsed and remaining so they reflect time-based duration' do
        score = Score::Unmeasured.new(120, parts: {
          "abc" => Part.new(Dynamics::P, dynamic_changes: {
              2 => Change::Gradual.new(Dynamics::F,2,1,3),
              7 => Change::Gradual.new(Dynamics::F,1,4,5)
          })
        })
        converter = UnmeasuredScoreConverter.new(score,200)
        parts = converter.convert_parts
        dcs = parts["abc"].dynamic_changes
        
        dcs.keys.should eq([4,14])
        dcs[4.0].should eq(Change::Gradual.new(Dynamics::F,4,2,6))
        dcs[14.0].should eq(Change::Gradual.new(Dynamics::F,2,8,10))
      end
    end
  end
  
  describe '#convert_program' do
    before :each do
      @prog = Program.new([0...4,2...5])
      @score = Score::Unmeasured.new(120, program: @prog)
      @converter = UnmeasuredScoreConverter.new(@score,200)
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
      converter = UnmeasuredScoreConverter.new(score,200)
      converter.convert_score.should be_a Score::Timed
    end
  
    it 'should use output from convert_program' do
      prog = Program.new([0...4,2...5])
      score = Score::Unmeasured.new(120, program: prog)
      converter = UnmeasuredScoreConverter.new(score,200)
      nscore = converter.convert_score
      nscore.program.should eq(converter.convert_program)
    end
    
    it 'should use output from convert_parts' do
      changeA = Change::Immediate.new(Dynamics::PP)
      changeB = Change::Gradual.new(Dynamics::F, 2)
      score = Score::Unmeasured.new(120,
        parts: {"simple" => Part.new(Dynamics::MP, dynamic_changes: { 1 => changeA, 3 => changeB })}
      )
      converter = UnmeasuredScoreConverter.new(score,200)
      nscore = converter.convert_score
      nscore.parts.should eq(converter.convert_parts)
    end
  end
end