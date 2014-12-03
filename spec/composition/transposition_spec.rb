require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'transpose' do
  it 'should map given notes to new notes, transposing by given diff' do
    notes = "/4A2,C2 /4D2,F2,Gb2 /8 /8E4".to_notes
    semitones = 3
    notes2 = transpose(notes,semitones)
    
    notes2.size.should eq(notes.size)
    notes2.each_index do |i|
      notes2[i].pitches.each_with_index do |pitch2,j|
        pitch = notes[i].pitches[j]
        pitch2.diff(pitch).should eq(semitones)
      end
    end
  end
end
