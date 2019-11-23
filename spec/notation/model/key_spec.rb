require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Key do
  describe '.major' do
    it 'should set triad to MAJOR' do
      k = Key.major(PitchClasses::C)
      expect(k.triad_type).to eq(Key::MAJOR)
      expect(k.accidental_type).to eq(Key::NONE)
    end
  end

  describe '.minor' do
    it 'should set triad to MINOR' do
      k = Key.minor(PitchClasses::A)
      expect(k.triad_type).to eq(Key::MINOR)
      expect(k.accidental_type).to eq(Key::NONE)
    end
  end

  describe '.new' do
    context 'given tonic_pc that is not in 0..11' do
      it 'should apply mod 12 to bring it in range' do
        { 12 => 0, 13 => 1, -1 => 11, 24 => 0, 18 => 6
        }.each do |t1,t2|
          expect(Key.major(t1).tonic_pc).to eq(t2)
        end
      end
    end

    context 'given tonic_pc in 0..11' do
      it 'should not change' do
        (0..11).each do |pc|
          expect(Key.major(pc).tonic_pc).to eq(pc)
        end
      end
    end

    context 'given triad that is not MAJOR or MINOR' do
      it 'should raise ArgumentError' do
        expect { Key.new(0, triad: :flipping) }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#flat?' do

    context 'given accidental type is FLAT' do
      it 'should return true' do
        expect(Key.major(PitchClasses::F).flat?).to be true
      end
    end
    context 'given accidental type is SHARP' do
      it 'should return false' do
        expect(Key.major(PitchClasses::D).flat?).to be false
      end
    end
    context 'given accidental type is NONE' do
      it 'should return false' do
        expect(Key.major(PitchClasses::C).flat?).to be false
      end
    end
  end

  describe '#sharp?' do
    context 'given accidental_pref is FLAT' do
      it 'should return false' do
        expect(Key.major(PitchClasses::F).sharp?).to be false
      end
    end
    context 'given accidental_pref is SHARP' do
      it 'should return true' do
        expect(Key.major(PitchClasses::D).sharp?).to be true
      end
    end
    context 'given accidental type is NONE' do
      it 'should return false' do
        expect(Key.major(PitchClasses::C).sharp?).to be false
      end
    end
  end

  describe '#major?' do
    context 'given triad is MAJOR' do
      it 'should return true' do
        expect(Key.major(0).major?).to be true
      end
    end
    context 'given triad is MINOR' do
      it 'should return false' do
        expect(Key.minor(0).major?).to be false
      end
    end
  end

  describe '#minor?' do
    context 'given triad is MAJOR' do
      it 'should return false' do
        expect(Key.major(0).minor?).to be false
      end
    end
    context 'given triad is MINOR' do
      it 'should return true' do
        expect(Key.minor(0).minor?).to be true
      end
    end
  end

  describe '#==' do
    context 'objects with different tonic_pc' do
      it 'should return false' do
        expect(Key.major(0)).to_not eq(Key.major(1))
      end
    end

    context 'objects with different triad' do
      it 'should return false' do
        expect(Key.major(0)).to_not eq(Key.minor(0))
      end
    end

    context 'objects with same tonic_pc and triad type' do
      it 'should return true' do
        expect(Key.major(0)).to eq(Key.major(0))
      end
    end
  end

  describe '#clone' do
    it 'should return a different, equal object' do
      k1 = Key.major(0)
      k2 = k1.clone
      expect(k1).to_not be k2
      expect(k1).to eq k2
    end
  end

  describe '#accidentals' do
    context 'C major or A minor' do
      it 'should have no accidentals' do
        expect(Keys::C_MAJOR.accidentals).to be_empty
        expect(Keys::A_MINOR.accidentals).to be_empty
      end
    end

    context 'F major or D minor' do
      it 'should have one flat' do
        expect(Keys::F_MAJOR.accidentals).to eq(Key::ACCIDENTALS[Key::FLAT].take(1))
        expect(Keys::D_MINOR.accidentals).to eq(Key::ACCIDENTALS[Key::FLAT].take(1))
      end
    end

    context 'Bb major or G minor' do
      it 'should have two flats' do
        expect(Keys::Bb_MAJOR.accidentals).to eq(Key::ACCIDENTALS[Key::FLAT].take(2))
        expect(Keys::G_MINOR.accidentals).to eq(Key::ACCIDENTALS[Key::FLAT].take(2))
      end
    end

    context 'Eb major or C minor' do
      it 'should have three flats' do
        expect(Keys::Eb_MAJOR.accidentals).to eq(Key::ACCIDENTALS[Key::FLAT].take(3))
        expect(Keys::C_MINOR.accidentals).to eq(Key::ACCIDENTALS[Key::FLAT].take(3))
      end
    end

    context 'Ab major or F minor' do
      it 'should have four flats' do
        expect(Keys::Ab_MAJOR.accidentals).to eq(Key::ACCIDENTALS[Key::FLAT].take(4))
        expect(Keys::F_MINOR.accidentals).to eq(Key::ACCIDENTALS[Key::FLAT].take(4))
      end
    end

    context 'Db major or Bb minor' do
      it 'should have five flats' do
        expect(Keys::Db_MAJOR.accidentals).to eq(Key::ACCIDENTALS[Key::FLAT].take(5))
        expect(Keys::Bb_MINOR.accidentals).to eq(Key::ACCIDENTALS[Key::FLAT].take(5))
      end
    end

    context 'Gb major or Eb minor' do
      it 'should have six flats' do
        expect(Keys::Gb_MAJOR.accidentals).to eq(Key::ACCIDENTALS[Key::FLAT].take(6))
        expect(Keys::Eb_MINOR.accidentals).to eq(Key::ACCIDENTALS[Key::FLAT].take(6))
      end
    end

    context 'G major or E minor' do
      it 'should have one sharp' do
        expect(Keys::G_MAJOR.accidentals).to eq(Key::ACCIDENTALS[Key::SHARP].take(1))
        expect(Keys::E_MINOR.accidentals).to eq(Key::ACCIDENTALS[Key::SHARP].take(1))
      end
    end

    context 'D major or B minor' do
      it 'should have two sharps' do
        expect(Keys::D_MAJOR.accidentals).to eq(Key::ACCIDENTALS[Key::SHARP].take(2))
        expect(Keys::B_MINOR.accidentals).to eq(Key::ACCIDENTALS[Key::SHARP].take(2))
      end
    end

    context 'A major or F# minor' do
      it 'should have three sharps' do
        expect(Keys::A_MAJOR.accidentals).to eq(Key::ACCIDENTALS[Key::SHARP].take(3))
        expect(Keys::Fs_MINOR.accidentals).to eq(Key::ACCIDENTALS[Key::SHARP].take(3))
      end
    end

    context 'E major or C# minor' do
      it 'should have four sharps' do
        expect(Keys::E_MAJOR.accidentals).to eq(Key::ACCIDENTALS[Key::SHARP].take(4))
        expect(Keys::Cs_MINOR.accidentals).to eq(Key::ACCIDENTALS[Key::SHARP].take(4))
      end
    end

    context 'B major or G# minor' do
      it 'should have five sharps' do
        expect(Keys::B_MAJOR.accidentals).to eq(Key::ACCIDENTALS[Key::SHARP].take(5))
        expect(Keys::Gs_MINOR.accidentals).to eq(Key::ACCIDENTALS[Key::SHARP].take(5))
      end
    end
  end

  describe '#pack' do
    it 'should return a Hash' do
      expect(Key.major(1).pack).to be_a Hash
    end
  end

  describe '.unpack' do
    it 'should return a Key object equal to the original' do
      k1 = Key.major(1)
      k2 = Key.unpack k1.pack
      expect(k2).to be_a Key
      expect(k2).to eq(k1)
    end
  end
end
