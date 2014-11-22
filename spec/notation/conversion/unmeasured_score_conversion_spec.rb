require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Score::Unmeasured do
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
    @score = Score::Unmeasured.new(120,
      parts: @parts,
      program: @prog,
      tempo_changes: tcs,
    )
  end

  describe '#note_offsets' do
    before(:all){ @noffs = @score.note_offsets }
    
    it 'should return an already-sorted array' do
      @noffs.should eq @noffs.sort
    end
    
    it 'should start with offset from start tempo/dynamic' do
      @noffs[0].should eq(0)
    end
    
    it 'should include offsets from tempo changes' do
      @score.tempo_changes.each do |noff,change|
        @noffs.should include(noff)
        @noffs.should include(noff + change.duration)
      end
    end
    
    it "should include offsets from each part's dynamic changes" do
      @score.parts.values.each do |part|
        part.dynamic_changes.each do |noff,change|
          @noffs.should include(noff)
          change.offsets(noff).each {|offset| @noffs.should include(offset) }
        end
      end
    end
    
    it 'should include offsets from program segments' do
      @score.program.segments.each do |seg|
        @noffs.should include(seg.first)
        @noffs.should include(seg.last)
      end
    end
  end
  
  describe '#to_timed' do
    it 'should use UnmeasuredScoreConverter#convert_score' do
      nscore1 = @score.to_timed(200)
      nscore2 = UnmeasuredScoreConverter.new(@score,200).convert_score
      nscore1.should eq(nscore2)
    end
  end
end
