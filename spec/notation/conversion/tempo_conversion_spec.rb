require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Tempo::QNPM do
  before :all do
    @tempo = Tempo::QNPM.new(60)
  end
  
  describe '#to_npm' do
    it 'should return a Tempo::NPM object' do
      @tempo.to_npm.should be_a Tempo::NPM
    end
    
    it 'should change tempo value to be 1/4th' do
      @tempo.to_npm.value.should eq(Rational(60,4))
    end
  end
  
  describe '#to_nps' do
    it 'should return a Tempo::NPS object' do
      @tempo.to_nps.should be_a Tempo::NPS
    end
    
    it 'should change tempo value to be 1/240th' do
      @tempo.to_nps.value.should eq(Rational(1,4))
    end
  end
  
  describe '#to_bpm' do
    it 'should return a Tempo::BPM object' do
      @tempo.to_bpm(Rational(1,4)).should be_a Tempo::BPM
    end
    
    it 'should divide tempo value by (4*beatdur)' do
      @tempo.to_bpm(Rational(1,4)).value.should eq(60)
      @tempo.to_bpm(Rational(1,2)).value.should eq(30)
    end
  end
end

describe Tempo::NPM do
  before :all do
    @tempo = Tempo::NPM.new(60)
  end
  
  describe '#to_qnpm' do
    it 'should return a Tempo::QNPM object' do
      @tempo.to_qnpm.should be_a Tempo::QNPM
    end
    
    it 'should multiply tempo value by 4' do
      @tempo.to_qnpm.value.should eq(240)
    end
  end
  
  describe '#to_nps' do
    it 'should return a Tempo::NPS object' do
      @tempo.to_nps.should be_a Tempo::NPS
    end
    
    it 'should change tempo value to be 1/60th' do
      @tempo.to_nps.value.should eq(1)
    end
  end
  
  describe '#to_bpm' do
    it 'should return a Tempo::BPM object' do
      @tempo.to_bpm(Rational(1,4)).should be_a Tempo::BPM
    end
    
    it 'should divide tempo value by beatdur' do
      @tempo.to_bpm(Rational(1,1)).value.should eq(60)
      @tempo.to_bpm(Rational(1,4)).value.should eq(240)
      @tempo.to_bpm(Rational(1,2)).value.should eq(120)
    end
  end
end

describe Tempo::NPS do
  before :all do
    @tempo = Tempo::NPS.new(1)
  end
  
  describe '#to_qnpm' do
    it 'should return a Tempo::QNPM object' do
      @tempo.to_qnpm.should be_a Tempo::QNPM
    end
    
    it 'should multiply tempo value by 240' do
      @tempo.to_qnpm.value.should eq(240)
    end
  end
  
  describe '#to_npm' do
    it 'should return a Tempo::NPM object' do
      @tempo.to_npm.should be_a Tempo::NPM
    end
    
    it 'should multiply tempo value by 60' do
      @tempo.to_npm.value.should eq(60)
    end
  end

  describe '#to_bpm' do
    it 'should return a Tempo::BPM object' do
      @tempo.to_bpm(Rational(1,4)).should be_a Tempo::BPM
    end
    
    it 'should multiply tempo value by 60/beatdur' do
      @tempo.to_bpm(Rational(1,1)).value.should eq(60)
      @tempo.to_bpm(Rational(1,4)).value.should eq(240)
      @tempo.to_bpm(Rational(1,2)).value.should eq(120)
    end
  end
end

describe Tempo::BPM do
  before :all do
    @tempo = Tempo::BPM.new(60)
  end
  
  describe '#to_npm' do
    it 'should return a Tempo::NPM object' do
      @tempo.to_npm(Rational(1,4)).should be_a Tempo::NPM
    end
    
    it 'should multiply tempo value by beatdur' do
      @tempo.to_npm(Rational(1,4)).value.should eq(15)
    end
  end
  
  describe '#to_nps' do
    it 'should return a Tempo::NPS object' do
      @tempo.to_nps(Rational(1,4)).should be_a Tempo::NPS
    end
    
    it 'should multiply tempo value by beatdur/60' do
      @tempo.to_nps(Rational(1,4)).value.should eq(Rational(1,4))
    end
  end
  
  describe '#to_qnpm' do
    it 'should return a Tempo::QNPM object' do
      @tempo.to_qnpm(Rational(1,4)).should be_a Tempo::QNPM
    end
    
    it 'should multiply tempo value by (4*beatdur)' do
      @tempo.to_qnpm(Rational(1,8)).value.should eq(30)
      @tempo.to_qnpm(Rational(1,4)).value.should eq(60)
      @tempo.to_qnpm(Rational(1,2)).value.should eq(120)
    end
  end
end
