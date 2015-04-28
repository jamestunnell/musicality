describe Score::Timed do
  before :all do
    @score = Score::Timed.new do |s|
      s.parts["rhand"] = Part.new(Dynamics::MF) do |p|
        p.notes += ("/2C4 "*2 + "/2G4 "*2 +
                    "/2A4 "*2 + "1G4").to_notes
      end
      s.parts["lhand"] = Part.new(Dynamics::MF) do |p|
        p.notes += ("1C3,E3,G3 "*2 + 
                    "1F2,A2,C3 1C3,E3,G3").to_notes
      end
      s.program.push 0...8
    end
  end
  
  describe '#to_midi_seq' do
    it 'should produce a MIDI::Sequence' do
      seq = @score.to_midi_seq
      seq.should be_a MIDI::Sequence
    end
  end  
end

describe Score::TempoBased do
  before :all do
    @score = Score::Measured.new(TWO_FOUR, 120) do |s|
      s.parts["rhand"] = Part.new(Dynamics::MF) do |p|
        p.notes += ("/4C4 "*2 + "/4G4 "*2 +
                    "/4A4 "*2 + "/2G4").to_notes
      end
      s.parts["lhand"] = Part.new(Dynamics::MF) do |p|
        p.notes += ("/2C3,E3,G3 "*2 + 
                    "/2F2,A2,C3 /2C3,E3,G3").to_notes
      end
      s.program.push 0...4
    end
  end

  describe '#to_midi_seq' do
    it 'should produce a MIDI::Sequence' do
      seq = @score.to_midi_seq 200
      seq.should be_a MIDI::Sequence
    end
  end
end
