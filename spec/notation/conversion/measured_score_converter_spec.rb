require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe MeasuredScoreConverter do
  describe '#initialize' do
    context 'current score is invalid' do
      it 'should raise NotValidError' do
        score = Score::Measured.new(1, 120)
        expect { MeasuredScoreConverter.new(score) }.to raise_error(NotValidError)
      end
    end    
  end
  
  describe '#convert_parts' do
    before :each do
      @changeA = Change::Immediate.new(Dynamics::PP)
      @changeB = Change::Gradual.new(Dynamics::F, 2)
      @score = Score::Measured.new(FOUR_FOUR, 120,
        parts: {"simple" => Part.new(Dynamics::MP, dynamic_changes: { 1 => @changeA, 3 => @changeB })}
      )
    end
    
    it 'should return Hash with original part names' do
      parts = MeasuredScoreConverter.new(@score).convert_parts
      parts.should be_a Hash
      parts.keys.sort.should eq(@score.parts.keys.sort)
    end
    
    it 'should convert part dynamic change offsets from measure-based to note-based' do
      parts = MeasuredScoreConverter.new(@score).convert_parts
      parts.should have_key("simple")
      part = parts["simple"]
      part.dynamic_changes.keys.sort.should eq([1,3])
      change = part.dynamic_changes[Rational(1,1)]
      change.value.should eq(@changeA.value)
      change.duration.should eq(0)
      change = part.dynamic_changes[Rational(3,1)]
      change.value.should eq(@changeB.value)
      change.duration.should eq(2)
      
      @score.start_meter = THREE_FOUR
      parts = MeasuredScoreConverter.new(@score).convert_parts
      parts.should have_key("simple")
      part = parts["simple"]
      part.dynamic_changes.keys.sort.should eq([Rational(3,4),Rational(9,4)])
      change = part.dynamic_changes[Rational(3,4)]
      change.value.should eq(@changeA.value)
      change.duration.should eq(0)
      change = part.dynamic_changes[Rational(9,4)]
      change.value.should eq(@changeB.value)
      change.duration.should eq(1.5)
    end
    
    context 'gradual changes with positive elapsed and/or remaining' do
      it 'should change elapsed and remaining so they reflect note-based offsets' do
        score = Score::Measured.new(THREE_FOUR,120, parts: {
          "abc" => Part.new(Dynamics::P, dynamic_changes: {
              2 => Change::Gradual.new(Dynamics::F,2,1,3),
              7 => Change::Gradual.new(Dynamics::F,1,4,5)
          })
        })
        converter = MeasuredScoreConverter.new(score)
        parts = converter.convert_parts
        dcs = parts["abc"].dynamic_changes
        
        dcs.keys.should eq([Rational(6,4), Rational(21,4)])
        dcs[Rational(3,2)].should eq(Change::Gradual.new(Dynamics::F,Rational(6,4),Rational(3,4),Rational(9,4)))
        dcs[Rational(21,4)].should eq(Change::Gradual.new(Dynamics::F,Rational(3,4),Rational(12,4),Rational(15,4)))
      end
    end
  end
  
  describe '#convert_program' do
    before :each do
      @prog = Program.new([0...4,2...5])
      @score = Score::Measured.new(FOUR_FOUR, 120, program: @prog)
      @converter = MeasuredScoreConverter.new(@score)
    end
    
    it 'shuld return Program with same number of segments' do
      prog = @converter.convert_program
      prog.should be_a Program
      prog.segments.size.should eq(@score.program.segments.size)
    end
  
    it 'should convert program segments offsets from measure-based to note-based' do
      prog = MeasuredScoreConverter.new(@score).convert_program
      prog.segments.size.should eq(2)
      prog.segments[0].first.should eq(0)
      prog.segments[0].last.should eq(4)
      prog.segments[1].first.should eq(2)
      prog.segments[1].last.should eq(5)
      
      @score.start_meter = THREE_FOUR
      prog = MeasuredScoreConverter.new(@score).convert_program
      prog.segments.size.should eq(2)
      prog.segments[0].first.should eq(0)
      prog.segments[0].last.should eq(3)
      prog.segments[1].first.should eq(1.5)
      prog.segments[1].last.should eq(3.75)
    end
  end
  
  describe '#convert_start_tempo' do
    it 'should return a converted tempo object, with same type as givn tempo class' do
      score = Score::Measured.new(SIX_EIGHT, 120)
      converter = MeasuredScoreConverter.new(score)
      tempo = converter.convert_start_tempo
      tempo.should eq(180)
    end
  end
  
  describe '#convert_tempo_changes' do
    context 'immediate tempo changes' do
      before :all do
        @score = Score::Measured.new(THREE_FOUR, 120,
          tempo_changes: { 1 => Change::Immediate.new(100),
            2.5 => Change::Immediate.new(90)}
        )
        @tcs = MeasuredScoreConverter.new(@score).convert_tempo_changes
      end
      
      it 'should change offset from measure-based to note-based' do
        @tcs.keys.sort.should eq([0.75, 1.875])
      end
      
      it 'should change tempo value using Tempo::BPM.to_qnpm' do
        @tcs.entries.first[1].value.should eq(Tempo::BPM.to_qnpm(100,Rational(1,4)))
        @tcs.entries.last[1].value.should eq(Tempo::BPM.to_qnpm(90,Rational(1,4)))
      end
    end
    
    context 'gradual tempo changes' do
      context 'no meter changes within tempo change duration' do
        before :all do
          @score = Score::Measured.new(THREE_FOUR, 120,
            tempo_changes: { 2 => Change::Gradual.new(100,2) },
            meter_changes: { 1 => Change::Immediate.new(TWO_FOUR),
                             4 => Change::Immediate.new(SIX_EIGHT) }
          )
          @tcs = MeasuredScoreConverter.new(@score).convert_tempo_changes
        end
  
        it 'should change tempo change offset to note-based' do
          @tcs.keys.should eq([Rational(5,4)])
        end
        
        it 'should convert the tempo change' do
          @tcs[Rational(5,4)].value.should eq(Tempo::BPM.to_qnpm(100,Rational(1,4)))
        end
        
        it 'should convert change duration to note-based' do
          @tcs[Rational(5,4)].duration.should eq(1)
        end
      end
      
      context 'single meter change within tempo change duration' do
        before :all do
          @tc_moff, @mc_moff = 2, 4
          @tc = Change::Gradual.new(100,4)
          @score = Score::Measured.new(THREE_FOUR, 120,
            tempo_changes: { @tc_moff => @tc },
            meter_changes: { @mc_moff => Change::Immediate.new(SIX_EIGHT) }
          )
          @tcs = MeasuredScoreConverter.new(@score).convert_tempo_changes
          @mnoff_map = @score.measure_note_map
          
          mend = @tc_moff + @tc.impending + @tc.remaining
          @ndur = @mnoff_map[mend] - @mnoff_map[mend - @tc.total_duration]
        end
  
        it 'should split the one gradual change into two, durations adding to original total' do
          @tcs.size.should eq(2)
          @tcs.values.each {|x| x.should be_a Change::Gradual }
        end
        
        it 'should make each with same total duration' do
          @tcs.values.each {|x| x.total_duration.should eq(@ndur) }
        end
        
        it 'should make durations so they sum to make the total duration' do
          @tcs.values.map {|x| x.duration }.inject(0,:+).should eq(@ndur)
        end
        
        it 'should start first split change where original change would start' do
          @tcs.should have_key(@mnoff_map[@tc_moff])
        end
        
        it 'should stop first split, and start second split where inner meter change occurs' do
          pc1_start_noff = @mnoff_map[@tc_moff]
          pc1_end_noff  = pc1_start_noff + @tcs[pc1_start_noff].duration
          
          pc2_start_noff = @mnoff_map[@mc_moff]
          @tcs.should have_key(pc2_start_noff)
          pc1_end_noff.should eq(pc2_start_noff)
        end
        
        it 'should stop second split change where original change would end' do
          pc2_start_noff = @mnoff_map[@mc_moff]
          pc2_end_noff = pc2_start_noff + @tcs[pc2_start_noff].duration
          pc2_end_noff.should eq(@mnoff_map[@tc_moff + @tc.duration])
        end
      end
  
      context 'two meter changes within tempo change duration' do
        before :all do
          @tc_moff, @mc1_moff, @mc2_moff = 2, 4, 5
          @tc = Change::Gradual.new(100,5)
          @score = Score::Measured.new(THREE_FOUR, 120,
            tempo_changes: { @tc_moff =>  @tc},
            meter_changes: { @mc1_moff => Change::Immediate.new(SIX_EIGHT),
                             @mc2_moff => Change::Immediate.new(TWO_FOUR) }
          )
          @tcs = MeasuredScoreConverter.new(@score).convert_tempo_changes
          @mnoff_map = @score.measure_note_map
          
          mend = @tc_moff + @tc.impending + @tc.remaining
          @ndur = @mnoff_map[mend] - @mnoff_map[mend - @tc.total_duration]
        end
  
        it 'should split the one gradual change into three' do
          @tcs.size.should eq(3)
          @tcs.values.each {|x| x.should be_a Change::Gradual }
        end
        
        it 'should make each with same total duration' do
          @tcs.values.each {|x| x.total_duration.should eq(@ndur) }
        end
        
        it 'should make durations so they sum to make the total duration' do
          @tcs.values.map {|x| x.duration }.inject(0,:+).should eq(@ndur)
        end
        
        it 'should start first split change where original change would start' do
          @tcs.should have_key(@mnoff_map[@tc_moff])
        end
        
        it 'should stop first split, and start second split change where 1st meter change occurs' do
          pc1_start_noff = @mnoff_map[@tc_moff]
          pc1_end_noff  = pc1_start_noff + @tcs[pc1_start_noff].duration
          
          pc2_start_noff = @mnoff_map[@mc1_moff]
          @tcs.should have_key(pc2_start_noff)
          pc1_end_noff.should eq(pc2_start_noff)
        end
        
        it 'should stop second split, and start third split change where 2st meter change occurs' do
          pc2_start_noff = @mnoff_map[@mc1_moff]
          pc2_end_noff  = pc2_start_noff + @tcs[pc2_start_noff].duration
          
          pc3_start_noff = @mnoff_map[@mc2_moff]
          @tcs.should have_key(pc3_start_noff)
          pc2_end_noff.should eq(pc3_start_noff)
        end
        
        it 'should stop third split change where original change would end' do
          pc3_start_noff = @mnoff_map[@mc2_moff]
          pc3_end_noff = pc3_start_noff + @tcs[pc3_start_noff].duration
          pc3_end_noff.should eq(@mnoff_map[@tc_moff + @tc.duration])
        end
      end
    end
    
    context 'gradual tempo changes with positive elapsed and/or remaining' do
      context 'no meter change during tempo change' do
        it 'should simply change elapsed and remaining so they reflect note-based offsets' do
          score = Score::Measured.new(THREE_FOUR,120, tempo_changes: {
            3 => Change::Gradual.new(100,5,2,3)
          })
          converter = MeasuredScoreConverter.new(score)
          tcs = converter.convert_tempo_changes
          
          tcs.keys.should eq([Rational(9,4)])
          tcs[Rational(9,4)].should eq(Change::Gradual.new(100,Rational(15,4),Rational(6,4),Rational(9,4)))
        end
      end
      
      context 'meter changes during tempo change' do
        it 'should split tempo change, converting and adjusting elapsed/remaining with each sub-change' do
          score = Score::Measured.new(THREE_FOUR,120,
            meter_changes: { 4 => Change::Immediate.new(SIX_EIGHT),
                             6 => Change::Immediate.new(TWO_FOUR) },
            tempo_changes: { 3 => Change::Gradual.new(100,5,2,3) }
          )
          converter = MeasuredScoreConverter.new(score)
          tcs = converter.convert_tempo_changes
          
          tcs.keys.should eq([Rational(9,4), Rational(12,4), Rational(18,4)])
          tcs[Rational(9,4)].should eq(Change::Gradual.new(100,0.75,1.5,4))
          tcs[Rational(12,4)].should eq(Change::Gradual.new(Tempo::BPM.to_qnpm(100,SIX_EIGHT.beat_duration),1.5,2.25,2.5))
          tcs[Rational(18,4)].should eq(Change::Gradual.new(Tempo::BPM.to_qnpm(100,TWO_FOUR.beat_duration),1,3.75,1.5))
        end
      end
    end
  end
  
  describe '#convert_score' do    
    it 'should return an unmeasured score' do
      score = Score::Measured.new(FOUR_FOUR, 120)
      converter = MeasuredScoreConverter.new(score)
      converter.convert_score.should be_a Score::Unmeasured
    end
  
    it 'should use output from convert_start_tempo' do
      score = Score::Measured.new(FOUR_FOUR, 120)
      converter = MeasuredScoreConverter.new(score)
      nscore = converter.convert_score
      nscore.start_tempo.should eq(converter.convert_start_tempo)
    end
    
    it 'should use output from convert_program' do
      prog = Program.new([0...4,2...5])
      score = Score::Measured.new(FOUR_FOUR, 120, program: prog)
      converter = MeasuredScoreConverter.new(score)
      nscore = converter.convert_score
      nscore.program.should eq(converter.convert_program)
    end
    
    it 'should use output from convert_parts' do
      changeA = Change::Immediate.new(Dynamics::PP)
      changeB = Change::Gradual.new(Dynamics::F, 2)
      score = Score::Measured.new(FOUR_FOUR, 120,
        parts: {"simple" => Part.new(Dynamics::MP, dynamic_changes: { 1 => changeA, 3 => changeB })}
      )
      converter = MeasuredScoreConverter.new(score)
      nscore = converter.convert_score
      nscore.parts.should eq(converter.convert_parts)
    end
  end
end