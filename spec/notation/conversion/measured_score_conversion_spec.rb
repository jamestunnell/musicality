require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Score::Measured do
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
      0 => Change::Immediate.new(120),
      4 => Change::Gradual.new(60,2),
      11 => Change::Immediate.new(110)
    }
    mcs = {
      1 => Change::Immediate.new(TWO_FOUR),
      3 => Change::Immediate.new(SIX_EIGHT)
    }
    @score = Score::Measured.new(THREE_FOUR, 120,
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
        @score2 = Score::Measured.new(FOUR_FOUR, 120, meter_changes: { 0 => @change })
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
        @score3 = Score::Measured.new(FOUR_FOUR, 120)
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
  
  describe '#to_unmeasured' do
    it 'should use MeasuredScoreConverter#convert_score' do
      nscore1 = @score.to_unmeasured
      nscore2 = MeasuredScoreConverter.new(@score).convert_score
      nscore1.should eq(nscore2)
    end
  end
end
