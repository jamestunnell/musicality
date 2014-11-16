require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Parsing::TempoParser do
  parser = Parsing::TempoParser.new
  
  [120,200,2.5,Rational(1,2),1.55e2].each do |val|
    [:bpm,:qnpm,:npm,:nps].each do |type|
      tempo = Tempo.const_get(type.upcase).new(val)
      str = tempo.to_s
      res = parser.parse(str)
      
      it "should parse #{str}" do
        res.should_not be nil
      end
      
      it 'should produce node that converts to back to original tempo via #to_tempo' do
        res.to_tempo.should eq(tempo)
      end
    end
  end
end
