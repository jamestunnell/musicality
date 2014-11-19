require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Tempo::QNPM do
  before :all do
    @tempo = 60
  end
  
  describe '#to_nps' do
    it 'should change tempo value to be 1/240th' do
      Tempo::QNPM.to_nps(@tempo).should eq(Rational(1,4))
    end
  end
  
  describe '#to_bpm' do
    it 'should divide tempo value by (4*beatdur)' do
      Tempo::QNPM.to_bpm(@tempo, Rational(1,4)).should eq(60)
      Tempo::QNPM.to_bpm(@tempo, Rational(1,2)).should eq(30)
    end
  end
end

describe Tempo::BPM do
  before :all do
    @tempo = 60
  end
  
  describe '#to_nps' do
    it 'should multiply tempo value by beatdur/60' do
      Tempo::BPM.to_nps(@tempo,Rational(1,4)).should eq(Rational(1,4))
    end
  end
  
  describe '#to_qnpm' do
    it 'should multiply tempo value by (4*beatdur)' do
      Tempo::BPM.to_qnpm(@tempo,Rational(1,8)).should eq(30)
      Tempo::BPM.to_qnpm(@tempo,Rational(1,4)).should eq(60)
      Tempo::BPM.to_qnpm(@tempo,Rational(1,2)).should eq(120)
    end
  end
end
