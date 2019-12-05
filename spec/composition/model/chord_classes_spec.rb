require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe ChordClasses do
  describe 'MAJ#to_pitch_seq' do
    it 'should produce a major triad' do
      pitches = ChordClasses::MAJ.to_pitch_seq(C4)
      expect(pitches.take(4).to_a).to eq([C4,E4,G4,C5])
      expect(pitches.take_back(3).to_a).to eq([G3,E3,C3])
    end
  end

  describe 'MIN#to_pitch_seq' do
    it 'should produce a minor triad' do
      pitches = ChordClasses::MIN.to_pitch_seq(C4)
      expect(pitches.take(4).to_a).to eq([C4,Eb4,G4,C5])
      expect(pitches.take_back(3).to_a).to eq([G3,Eb3,C3])
    end
  end

  describe 'DOM_7#to_pitch_seq' do
    it 'should produce a major triad plus flatted 7' do
      pitches = ChordClasses::DOM_7.to_pitch_seq(C4)
      expect(pitches.take(5).to_a).to eq([C4,E4,G4,Bb4,C5])
      expect(pitches.take_back(4).to_a).to eq([Bb3,G3,E3,C3])
    end
  end

  describe 'MAJ_9#to_pitch_seq' do
    it 'should produce a major triad plus major 7 plus major 9' do
      pitches = ChordClasses::MAJ_9.to_pitch_seq(C4)
      expect(pitches.take(6).to_a).to eq([C4,E4,G4,B4,D5,C5])
      expect(pitches.take_back(5).to_a).to eq([D4,B3,G3,E3,C3])
    end
  end
end
