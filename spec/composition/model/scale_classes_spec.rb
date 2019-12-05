require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe ScaleClasses do
  describe 'CHROMATIC#to_pitch_seq' do
    it 'should produce a chromatic scale' do
      pitches = ScaleClasses::CHROMATIC.to_pitch_seq(C4)
      expect(pitches.take(13).to_a).to eq([C4,Db4,D4,Eb4,E4,F4,Gb4,G4,Ab4,A4,Bb4,B4,C5])
      expect(pitches.take_back(12).to_a).to eq([B3,Bb3,A3,Ab3,G3,Gb3,F3,E3,Eb3,D3,Db3,C3])
    end
  end

  describe 'Heptatonic::Prima::MAJOR#to_pitch_seq' do
    it 'should produce a major scale' do
      pitches = ScaleClasses::Heptatonic::Prima::MAJOR.to_pitch_seq(C4)
      expect(pitches.take(8).to_a).to eq([C4,D4,E4,F4,G4,A4,B4,C5])
      expect(pitches.take_back(7).to_a).to eq([B3,A3,G3,F3,E3,D3,C3])
    end
  end
end
