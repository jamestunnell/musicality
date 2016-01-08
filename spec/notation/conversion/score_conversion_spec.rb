require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Score::Tempo do
  before :all do
    @parts = {
      "piano" => Part.new(Dynamics::MP,
        notes: [Note.quarter(C4), Note.eighth(F3), Note.whole(C4), Note.half(D4)]*12,
        dynamic_changes: {
          1 => Change::Immediate.new(Dynamics::MF),
          5 => Change::Immediate.new(Dynamics::FF),
          6 => Change::Gradual.linear(Dynamics::MF,2),
          14 => Change::Immediate.new(Dynamics::PP),
        }
      )
    }
    @prog = [0...3,4...7,1...20,17..."45/2".to_r]
    tcs = {
      0 => Change::Immediate.new(120),
      4 => Change::Gradual.linear(60,2),
      11 => Change::Immediate.new(110)
    }
    mcs = {
      1 => Change::Immediate.new(TWO_FOUR),
      3 => Change::Immediate.new(SIX_EIGHT)
    }
    @score = Score::Tempo.new(THREE_FOUR, 120,
      parts: @parts,
      program: @prog,
      tempo_changes: tcs,
      meter_changes: mcs
    )
  end

  describe '#to_timed' do
    it 'should use ScoreConverter#convert_score' do
      nscore1 = @score.to_timed(200)
      nscore2 = ScoreConverter.new(@score,200).convert_score
      nscore1.should eq(nscore2)
    end
  end
end
