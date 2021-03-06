require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe MidiUtil do
  describe '.pitch_to_notenum' do
    context 'given C4' do
      it 'should return 60' do
        expect(MidiUtil.pitch_to_notenum(C4)).to eq(60)
      end
    end

    context 'given A4' do
      it 'should return 69' do
        expect(MidiUtil.pitch_to_notenum(A4)).to eq(69)
      end
    end

    context 'given octave below C0' do
      it 'should return 0' do
        expect(MidiUtil.pitch_to_notenum(Pitch.new(octave:-1))).to eq(0)
      end
    end

    context 'given G9' do
      it 'should return 127' do
        expect(MidiUtil.pitch_to_notenum(G9)).to eq(127)
      end
    end

    context 'given pitch between C-1 to G9 range' do
      it 'should pitch diff from C4 should equal notenum diff' do
        c4_nn = MidiUtil.pitch_to_notenum(C4)
         [C2,D2,Eb2,F2,A2,Bb3,C3,G3,Gb4,F5,A5,Bb5,C6].each do |pitch|
          nn = MidiUtil.pitch_to_notenum(pitch)
          expect(C4.diff(pitch)).to eq(c4_nn - nn)
        end
      end
    end

    context 'given pitch outside C-1 to G9 range' do
      it 'should raise error' do
        expect { MidiUtil.pitch_to_notenum(Pitch.new(octave:-2)) }.to raise_error(KeyError)
        expect { MidiUtil.pitch_to_notenum(Ab9) }.to raise_error(KeyError)
      end
    end
  end

  describe '.notenum_to_pitch' do
    context 'given 60' do
      it 'should return C4' do
        expect(MidiUtil.notenum_to_pitch(60)).to eq(C4)
      end
    end

    context 'given 69' do
      it 'should return A4' do
        expect(MidiUtil.notenum_to_pitch(69)).to eq(A4)
      end
    end

    context 'given 0' do
      it 'should return octave below C0' do
        expect(MidiUtil.notenum_to_pitch(0)).to eq(Pitch.new(octave:-1))
      end
    end

    context 'given 127' do
      it 'should return G9' do
        expect(MidiUtil.notenum_to_pitch(127)).to eq(G9)
      end
    end
  end

  describe '.dynamic_to_volume' do
    context 'given 0' do
      it 'should return 0' do
        expect(MidiUtil.dynamic_to_volume(0)).to eq(0)
      end
    end

    context 'given 1' do
      it 'should return 0' do
        expect(MidiUtil.dynamic_to_volume(1)).to eq(127)
      end
    end

    context 'given 0.5' do
      it 'should return 64' do
        expect(MidiUtil.dynamic_to_volume(0.5)).to eq(64)
      end
    end
  end

  describe 'note_velocity' do
    context 'given Attack::NORMAL' do
      it 'should return a value at least that of when given Attack::NONE' do
        expect(MidiUtil.note_velocity(Attack::NORMAL)).to be >= MidiUtil.note_velocity(Attack::NONE)
      end

      it 'should return a value between 0 and 127' do
        expect(MidiUtil.note_velocity(Attack::NORMAL)).to be_between(0,127)
      end
    end

    context 'given Attack::TENUTO' do
      it 'should return a higher value than when given Attack::NORMAL' do
        expect(MidiUtil.note_velocity(Attack::TENUTO)).to be > MidiUtil.note_velocity(Attack::NORMAL)
      end

      it 'should return a value between 0 and 127' do
        expect(MidiUtil.note_velocity(Attack::TENUTO)).to be_between(0,127)
      end
    end

    context 'given Attack::ACCENT' do
      it 'should return a higher value than when given Attack::TENUTO' do
        expect(MidiUtil.note_velocity(Attack::ACCENT)).to be > MidiUtil.note_velocity(Attack::TENUTO)
      end

      it 'should return a value between 0 and 127' do
        expect(MidiUtil.note_velocity(Attack::ACCENT)).to be_between(0,127)
      end
    end
  end

  describe '.delta' do
    context 'given 1/4' do
      it 'should return the given ppqn' do
        expect(MidiUtil.delta(Rational(1,4),20)).to eq(20)
      end
    end

    context 'given 1/2' do
      it 'should return twice the given ppqn' do
        expect(MidiUtil.delta(Rational(1,2),20)).to eq(40)
      end
    end

    context 'given 1/8' do
      it 'should return half the given ppqn' do
        expect(MidiUtil.delta(Rational(1,8),20)).to eq(10)
      end
    end

    it 'should return an integer' do
      (0.1...1.1).step(0.1).each do |dur|
        expect(MidiUtil.delta(dur,100)).to be_an(Integer)
      end
    end
  end
end
