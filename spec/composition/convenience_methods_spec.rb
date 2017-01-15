require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'transpose' do
  it 'should map given notes to new notes, transposing by given diff' do
    notes = "/4A2,C2 /4D2,F2,Gb2 /8 /8E4".to_notes
    semitones = 3
    notes2 = transpose(notes,semitones)

    expect(notes2.size).to eq(notes.size)
    notes2.each_index do |i|
      notes2[i].pitches.each_with_index do |pitch2,j|
        pitch = notes[i].pitches[j]
        expect(pitch2.diff(pitch)).to eq(semitones)
      end
    end
  end
end

{
  :s => "1/16".to_r,
  :ds => "3/32".to_r,
  :e => "1/8".to_r,
  :de => "3/16".to_r,
  :q => "1/4".to_r,
  :dq => "3/8".to_r,
  :h => "1/2".to_r,
  :dh => "3/4".to_r,
  :w => '1'.to_r
}.each do |method,dur|
  describe method do
    context 'given no args' do
      it 'should produce an empty array' do
        expect(send(method)).to eq([])
      end
    end

    context 'given one pitch' do
      it 'should produce an array with one note, with proper duration' do
        expect(send(method,*[C2])).to eq([Note.new(dur,C2)])
      end
    end

    context 'given one pitch group' do
      it 'should produce an array with one note, given pitch group, and with proper duration' do
        expect(send(method,*[[C2,E2,G2]])).to eq([Note.new(dur,[C2,E2,G2])])
      end
    end

    context 'given many pitch groups' do
      it 'should produce an array of notes with same pitch groups, and with proper duration' do
        pg1 = A3
        pg2 = [B3,G3]
        pg3 = F4
        expect(send(method,*[pg1,pg2,pg3])).to eq([
          Note.new(dur,pg1), Note.new(dur,pg2), Note.new(dur,pg3)
        ])
      end
    end
  end
end
