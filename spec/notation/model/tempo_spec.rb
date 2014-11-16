require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Tempo do
  describe '#initialize' do
    it 'should assign given value' do
      Tempo.new(3).value.should eq(3)
    end
    
    context 'given negative value' do
      it 'should raise NonPositiveError' do
        expect { Tempo.new(-3) }.to raise_error(NonPositiveError)
      end
    end
  end
  
  [ :qnpm, :bpm, :npm, :nps ].each do |sym|
    describe "Tempo::#{sym}" do
      it "should print tempo value + '#{sym}'" do
        klass = Tempo.const_get(sym.upcase)
        klass.new(20).to_s.should eq("20#{sym}")
      end
    end
  end
end
