require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Key do
  describe '.major_flat' do
    it 'should set triad to MAJOR and accidental_pref to FLAT' do
      k = Key.major_flat(0)
      expect(k.triad).to eq(Key::MAJOR)
      expect(k.accidental_pref).to eq(Key::FLAT)
    end
  end

  describe '.minor_flat' do
    it 'should set triad to MAJOR and accidental_pref to SHARP' do
      k = Key.major_sharp(0)
      expect(k.triad).to eq(Key::MAJOR)
      expect(k.accidental_pref).to eq(Key::SHARP)
    end
  end

  describe '.major_sharp' do
    it 'should set triad to MINOR and accidental_pref to FLAT' do
      k = Key.minor_flat(0)
      expect(k.triad).to eq(Key::MINOR)
      expect(k.accidental_pref).to eq(Key::FLAT)
    end
  end

  describe '.minor_sharp' do
    it 'should set triad to MINOR and accidental_pref to SHARP' do
      k = Key.minor_sharp(0)
      expect(k.triad).to eq(Key::MINOR)
      expect(k.accidental_pref).to eq(Key::SHARP)
    end
  end

  describe '.new' do
    context 'given tonic_pc that is not in 0..11' do
      it 'should apply mod 12 to bring it in range' do
        { 12 => 0, 13 => 1, -1 => 11, 24 => 0, 18 => 6
        }.each do |t1,t2|
          expect(Key.major_flat(t1).tonic_pc).to eq(t2)
        end
      end
    end

    context 'given tonic_pc in 0..11' do
      it 'should not change' do
        (0..11).each do |pc|
          expect(Key.major_flat(pc).tonic_pc).to eq(pc)
        end
      end
    end

    context 'given triad that is not MAJOR or MINOR' do
      it 'should raise ArgumentError' do
        expect { Key.new(0, triad: :flipping) }.to raise_error(ArgumentError)
      end
    end

    context 'given accidental_pref that is not FLAT or SHARP' do
      it 'should raise ArgumentError' do
        expect { Key.new(0, accidental_pref: :squiggle) }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#flat?' do
    context 'given accidental_pref is FLAT' do
      it 'should return true' do
        expect(Key.major_flat(0).flat?).to be true
      end
    end
    context 'given accidental_pref is SHARP' do
      it 'should return false' do
        expect(Key.major_sharp(0).flat?).to be false
      end
    end
  end

  describe '#sharp?' do
    context 'given accidental_pref is FLAT' do
      it 'should return false' do
        expect(Key.major_flat(0).sharp?).to be false
      end
    end
    context 'given accidental_pref is SHARP' do
      it 'should return true' do
        expect(Key.major_sharp(0).sharp?).to be true
      end
    end
  end

  describe '#major?' do
    context 'given triad is MAJOR' do
      it 'should return true' do
        expect(Key.major_flat(0).major?).to be true
      end
    end
    context 'given triad is MINOR' do
      it 'should return false' do
        expect(Key.minor_flat(0).major?).to be false
      end
    end
  end

  describe '#minor?' do
    context 'given triad is MAJOR' do
      it 'should return false' do
        expect(Key.major_flat(0).minor?).to be false
      end
    end
    context 'given triad is MINOR' do
      it 'should return true' do
        expect(Key.minor_flat(0).minor?).to be true
      end
    end
  end

  describe '#==' do
    context 'objects with different tonic_pc' do
      it 'should return false' do
        expect(Key.major_flat(0)).to_not eq(Key.major_flat(1))
      end
    end

    context 'objects with different triad' do
      it 'should return false' do
        expect(Key.major_flat(0)).to_not eq(Key.minor_flat(0))
      end
    end

    context 'objects with different accidental_type' do
      it 'should return false' do
        expect(Key.major_flat(0)).to_not eq(Key.major_sharp(0))
      end
    end

    context 'objects with same tonic_pc, triad, and accidental_type' do
      it 'should return true' do
        expect(Key.major_flat(0)).to eq(Key.major_flat(0))
      end
    end
  end

  describe '#clone' do
    it 'should return a different, equal object' do
      k1 = Key.major_flat(0)
      k2 = k1.clone
      expect(k1).to_not be k2
      expect(k1).to eq k2
    end
  end

  describe '#accidentals' do
  end

  describe '#pack' do
    it 'should return a Hash' do
      expect(Key.major_sharp(1).pack).to be_a Hash
    end
  end

  describe '.unpack' do
    it 'should return a Key object equal to the original' do
      k1 = Key.major_sharp(1)
      k2 = Key.unpack k1.pack
      expect(k2).to be_a Key
      expect(k2).to eq(k1)
    end
  end
end
