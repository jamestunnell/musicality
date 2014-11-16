require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Parsing::PitchParser do
  before :all do
    @parser = Parsing::PitchParser.new
  end
  
  ["C4","C#9","Ab0","G#2","E2+22","Cb5-99","G200","Bb9951+3920"
  ].each do |str|
    it "should parse #{str}" do
      @parser.should parse(str)
    end
  end
end
