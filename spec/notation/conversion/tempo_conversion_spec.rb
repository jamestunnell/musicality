require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Tempo::QNPM do
  before :all do
    @tempo = 60
  end

  describe '#to_nps' do
    it 'should change tempo value to be 1/240th' do
      expect(Tempo::QNPM.to_nps(@tempo)).to eq(Rational(1,4))
    end
  end

  describe '#to_bpm' do
    it 'should divide tempo value by (4*beatdur)' do
      expect(Tempo::QNPM.to_bpm(@tempo, Rational(1,4))).to eq(60)
      expect(Tempo::QNPM.to_bpm(@tempo, Rational(1,2))).to eq(30)
    end
  end
end

describe Tempo::BPM do
  before :all do
    @tempo = 60
  end

  describe '#to_nps' do
    it 'should multiply tempo value by beatdur/60' do
      expect(Tempo::BPM.to_nps(@tempo,Rational(1,4))).to eq(Rational(1,4))
    end
  end

  describe '#to_qnpm' do
    it 'should multiply tempo value by (4*beatdur)' do
      expect(Tempo::BPM.to_qnpm(@tempo,Rational(1,8))).to eq(30)
      expect(Tempo::BPM.to_qnpm(@tempo,Rational(1,4))).to eq(60)
      expect(Tempo::BPM.to_qnpm(@tempo,Rational(1,2))).to eq(120)
    end
  end
end
