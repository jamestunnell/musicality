require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe MeasureScore do
  before :all do
    @parts = {
      "piano" => Part.new(Dynamics::MP,
        notes: [Note.quarter(C4), Note.eighth(F3), Note.whole(C4), Note.half(D4)]*12,
        dynamic_changes: {
          1 => Change::Immediate.new(Dynamics::MF),
          5 => Change::Immediate.new(Dynamics::FF),
          6 => Change::Gradual.new(Dynamics::MF,2),
          14 => Change::Immediate.new(Dynamics::PP),
        }
      )
    }
    @prog = Program.new([0...3,4...7,1...20,17..."45/2".to_r])
    tcs = {
      0 => Change::Immediate.new(Tempo::BPM.new(120)),
      4 => Change::Gradual.new(Tempo::BPM.new(60),2),
      11 => Change::Immediate.new(Tempo::BPM.new(110))
    }
    mcs = {
      1 => Change::Immediate.new(TWO_FOUR),
      3 => Change::Immediate.new(SIX_EIGHT)
    }
    @score = MeasureScore.new(THREE_FOUR, Tempo::BPM.new(120),
      parts: @parts,
      program: @prog,
      tempo_changes: tcs,
      meter_changes: mcs
    )
  end

  describe '#measure_offsets' do
    before(:all){ @moffs = @score.measure_offsets }
    
    it 'should return an already-sorted array' do
      @moffs.should eq @moffs.sort
    end
    
    it 'should start with offset from start tempo/meter/dynamic' do
      @moffs[0].should eq(0)
    end
    
    it 'should include offsets from tempo changes' do
      @score.tempo_changes.each do |moff,change|
        @moffs.should include(moff)
        @moffs.should include(moff + change.duration)
      end
    end
    
    it 'should include offsets from meter changes' do
      @score.meter_changes.keys.each {|moff| @moffs.should include(moff) }
    end
    
    it "should include offsets from each part's dynamic changes" do
      @score.parts.values.each do |part|
        part.dynamic_changes.each do |moff,change|
          @moffs.should include(moff)
          @moffs.should include(moff + change.duration)
        end
      end
    end
    
    it 'should include offsets from program segments' do
      @score.program.segments.each do |seg|
        @moffs.should include(seg.first)
        @moffs.should include(seg.last)
      end
    end
  end
  
  describe '#measure_durations' do
    before(:all){ @mdurs = @score.measure_durations }
    
    it 'should return a Hash' do
      @mdurs.should be_a Hash
    end
    
    context 'no meter change at offset 0' do
      it 'should have size of meter_changes.size + 1' do
        @mdurs.size.should eq(@score.meter_changes.size + 1)
      end
      
      it 'should begin with offset 0' do
        @mdurs.keys.min.should eq(0)
      end
      
      it 'should map start meter to offset 0' do
        @mdurs[0].should eq(@score.start_meter.measure_duration)
      end
    end
    
    context 'meter change at offset 0' do
      before :all do
        @change = Change::Immediate.new(THREE_FOUR)
        @score2 = MeasureScore.new(FOUR_FOUR, Tempo::BPM.new(120), meter_changes: { 0 => @change })
        @mdurs2 = @score2.measure_durations
      end
  
      it 'should have same size as meter changes' do
        @mdurs2.size.should eq(@score2.meter_changes.size)
      end
      
      it 'should begin with offset 0' do
        @mdurs2.keys.min.should eq(0)
      end
      
      it 'should begin with meter change at offset 0, instead of start meter' do
        @mdurs2[0].should eq(@change.value.measure_duration)
      end
    end
    
    context 'no meter changes' do
      before :all do
        @score3 = MeasureScore.new(FOUR_FOUR, Tempo::BPM.new(120))
        @mdurs3 = @score3.measure_durations
      end
  
      it 'should have size 1' do
        @mdurs3.size.should eq(1)
      end
      
      it 'should begin with offset 0' do
        @mdurs3.keys.min.should eq(0)
      end
      
      it 'should begin with start meter' do
        @mdurs3[0].should eq(@score3.start_meter.measure_duration)
      end
    end
  end
    
  describe '#covert_parts' do
    before :each do
      @changeA = Change::Immediate.new(Dynamics::PP)
      @changeB = Change::Gradual.new(Dynamics::F, 2)
      @score = MeasureScore.new(FOUR_FOUR, Tempo::BPM.new(120),
        parts: {"simple" => Part.new(Dynamics::MP, dynamic_changes: { 1 => @changeA, 3 => @changeB })}
      )
    end
    
    it 'should return Hash with original part names' do
      parts = @score.convert_parts
      parts.should be_a Hash
      parts.keys.sort.should eq(@score.parts.keys.sort)
    end
    
    it 'should convert part dynamic change offsets from measure-based to note-based' do
      parts = @score.convert_parts
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
      parts = @score.convert_parts
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
  end
  
  describe '#convert_program' do
    before :each do
      @prog = Program.new([0...4,2...5])
      @score = MeasureScore.new(FOUR_FOUR, Tempo::BPM.new(120), program: @prog)
    end
    
    it 'shuld return Program with same number of segments' do
      prog = @score.convert_program
      prog.should be_a Program
      prog.segments.size.should eq(@score.program.segments.size)
    end
  
    it 'should convert program segments offsets from measure-based to note-based' do
      prog = @score.convert_program
      prog.segments.size.should eq(2)
      prog.segments[0].first.should eq(0)
      prog.segments[0].last.should eq(4)
      prog.segments[1].first.should eq(2)
      prog.segments[1].last.should eq(5)
      
      @score.start_meter = THREE_FOUR
      prog = @score.convert_program
      prog.segments.size.should eq(2)
      prog.segments[0].first.should eq(0)
      prog.segments[0].last.should eq(3)
      prog.segments[1].first.should eq(1.5)
      prog.segments[1].last.should eq(3.75)
    end
  end
  
  describe '#convert_tempo_changes' do
    context 'immediate tempo changes' do
      before :all do
        @score = MeasureScore.new(THREE_FOUR, Tempo::BPM.new(120),
          tempo_changes: { 1 => Change::Immediate.new(Tempo::BPM.new(100)),
            2.5 => Change::Immediate.new(Tempo::NPS.new(1.5)),
          4 => Change::Immediate.new(Tempo::NPM.new(22.5)),
          7 => Change::Immediate.new(Tempo::QNPM.new(90)) }
        )
        @tempo_type = Tempo::QNPM
        @tcs = @score.convert_tempo_changes(@tempo_type)
      end
      
      it 'should change offset from measure-based to note-based' do
        @tcs.keys.sort.should eq([0.75, 1.875, 3, 5.25])
      end
      
      it 'should convert tempo type to given type' do
        @tcs.values.each {|change| change.value.should be_a @tempo_type }
      end
    end
    
    context 'gradual tempo changes' do
      context 'no meter changes within tempo change duration' do
        before :all do
          @score = MeasureScore.new(THREE_FOUR, Tempo::BPM.new(120),
            tempo_changes: { 2 => Change::Gradual.new(Tempo::BPM.new(100),2) },
            meter_changes: { 1 => Change::Immediate.new(TWO_FOUR),
                             4 => Change::Immediate.new(SIX_EIGHT) }
          )
          @tempo_type = Tempo::QNPM
          @tcs = @score.convert_tempo_changes(@tempo_type)
        end
  
        it 'should change tempo change offset to note-based' do
          @tcs.keys.should eq([Rational(5,4)])
        end
        
        it 'should convert the tempo change' do
          @tcs[Rational(5,4)].value.should be_a @tempo_type
        end
        
        it 'should convert change duration to note-based' do
          @tcs[Rational(5,4)].duration.should eq(1)
        end
      end
      
      context 'single meter change within tempo change duration' do
        before :all do
          @tc_moff, @mc_moff = 2, 4
          @tc_dur = 4
          @score = MeasureScore.new(THREE_FOUR, Tempo::BPM.new(120),
            tempo_changes: { @tc_moff => Change::Gradual.new(Tempo::BPM.new(100),@tc_dur) },
            meter_changes: { @mc_moff => Change::Immediate.new(SIX_EIGHT) }
          )
          @tempo_type = Tempo::QNPM
          @tcs = @score.convert_tempo_changes(@tempo_type)
          @mnoff_map = @score.measure_note_map
        end
  
        it 'should split the one gradual change into two partial changes' do
          @tcs.size.should eq(2)
          @tcs.values.each {|x| x.should be_a Change::Partial }
        end
        
        it 'should start first partial change where gradual change would start' do
          @tcs.should have_key(@mnoff_map[@tc_moff])
        end
        
        it 'should stop first partial, and start second partial change where inner meter change occurs' do
          pc1_start_noff = @mnoff_map[@tc_moff]
          pc1_end_noff  = pc1_start_noff + @tcs[pc1_start_noff].duration
          
          pc2_start_noff = @mnoff_map[@mc_moff]
          @tcs.should have_key(pc2_start_noff)
          pc1_end_noff.should eq(pc2_start_noff)
        end
        
        it 'should stop second partial change where gradual change would end' do
          pc2_start_noff = @mnoff_map[@mc_moff]
          pc2_end_noff = pc2_start_noff + @tcs[pc2_start_noff].duration
          pc2_end_noff.should eq(@mnoff_map[@tc_moff + @tc_dur])
        end
      end

      context 'two meter changes within tempo change duration' do
        before :all do
          @tc_moff, @mc1_moff, @mc2_moff = 2, 4, 5
          @tc_dur = 5
          @score = MeasureScore.new(THREE_FOUR, Tempo::BPM.new(120),
            tempo_changes: { @tc_moff => Change::Gradual.new(Tempo::BPM.new(100),@tc_dur) },
            meter_changes: { @mc1_moff => Change::Immediate.new(SIX_EIGHT),
                             @mc2_moff => Change::Immediate.new(TWO_FOUR) }
          )
          @tempo_type = Tempo::QNPM
          @tcs = @score.convert_tempo_changes(@tempo_type)
          @mnoff_map = @score.measure_note_map
        end
  
        it 'should split the one gradual change into three partial changes' do
          @tcs.size.should eq(3)
          @tcs.values.each {|x| x.should be_a Change::Partial }
        end
        
        it 'should start first partial change where gradual change would start' do
          @tcs.should have_key(@mnoff_map[@tc_moff])
        end
        
        it 'should stop first partial, and start second partial change where 1st meter change occurs' do
          pc1_start_noff = @mnoff_map[@tc_moff]
          pc1_end_noff  = pc1_start_noff + @tcs[pc1_start_noff].duration
          
          pc2_start_noff = @mnoff_map[@mc1_moff]
          @tcs.should have_key(pc2_start_noff)
          pc1_end_noff.should eq(pc2_start_noff)
        end
        
        it 'should stop second partial, and start third partial change where 2st meter change occurs' do
          pc2_start_noff = @mnoff_map[@mc1_moff]
          pc2_end_noff  = pc2_start_noff + @tcs[pc2_start_noff].duration
          
          pc3_start_noff = @mnoff_map[@mc2_moff]
          @tcs.should have_key(pc3_start_noff)
          pc2_end_noff.should eq(pc3_start_noff)
        end
        
        it 'should stop third partial change where gradual change would end' do
          pc3_start_noff = @mnoff_map[@mc2_moff]
          pc3_end_noff = pc3_start_noff + @tcs[pc3_start_noff].duration
          pc3_end_noff.should eq(@mnoff_map[@tc_moff + @tc_dur])
        end
      end
    end
    
    context 'partial tempo changes' do
      it 'should raise NotImplementedError' do
        @score = MeasureScore.new(THREE_FOUR, Tempo::BPM.new(120),
          tempo_changes: { 1 => Change::Partial.new(Tempo::BPM.new(100),10,2,3)}
        )
        expect { @score.convert_tempo_changes(Tempo::QNPM) }.to raise_error(NotImplementedError)
      end
    end
  end
  
  describe '#to_note_score' do
    context 'current score is invalid' do
      it 'should raise NotValidError' do
        score = MeasureScore.new(1, Tempo::BPM.new(120))
        expect { score.to_note_score }.to raise_error(NotValidError)
      end
    end
    
    context 'given desired tempo class is not valid for NoteScore' do
      it 'should raise TypeError' do
        score = MeasureScore.new(FOUR_FOUR, Tempo::BPM.new(120))
        expect {score.to_note_score(Tempo::BPM) }.to raise_error(TypeError)
      end
    end
    
    it 'should return a NoteScore' do
      score = MeasureScore.new(FOUR_FOUR, Tempo::BPM.new(120))
      score.to_note_score(Tempo::QNPM).should be_a NoteScore
    end
  
    it 'should convert start tempo according to given desired tempo class' do
      score = MeasureScore.new(FOUR_FOUR, Tempo::BPM.new(120))
      { Tempo::QNPM => 120, Tempo::NPM => 30, Tempo::NPS => 0.5 }.each do |tempo_class, tgt_val|
        nscore = score.to_note_score(tempo_class)
        nscore.start_tempo.should be_a tempo_class
        nscore.start_tempo.value.should eq(tgt_val)
      end
    end
    
    it 'should use output from convert_program' do
      prog = Program.new([0...4,2...5])
      score = MeasureScore.new(FOUR_FOUR, Tempo::BPM.new(120), program: prog)
      nscore = score.to_note_score(Tempo::QNPM)
      nscore.program.should eq(score.convert_program)
    end
    
    it 'should use output from convert_parts' do
      changeA = Change::Immediate.new(Dynamics::PP)
      changeB = Change::Gradual.new(Dynamics::F, 2)
      score = MeasureScore.new(FOUR_FOUR, Tempo::BPM.new(120),
        parts: {"simple" => Part.new(Dynamics::MP, dynamic_changes: { 1 => changeA, 3 => changeB })}
      )
      nscore = score.to_note_score(Tempo::QNPM)
      nscore.parts.should eq(score.convert_parts)
    end
  
    it 'should use output from convert_program' do
      changeA = Change::Immediate.new(Dynamics::PP)
      changeB = Change::Gradual.new(Dynamics::F, 2)
      score = MeasureScore.new(FOUR_FOUR, Tempo::BPM.new(120),
        parts: {"simple" => Part.new(Dynamics::MP, dynamic_changes: { 1 => changeA, 3 => changeB })}
      )
      nscore = score.to_note_score(Tempo::QNPM)
      nscore.parts.should eq(score.convert_parts)
    end
  end
end
