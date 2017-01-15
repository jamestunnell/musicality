require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Parsing::ArticulationParser do
  parser = Parsing::ArticulationParser.new

  ARTICULATION_SYMBOLS.each do |art,str|
    res = parser.parse(str)
    it "should parse '#{str}'" do
      expect(res).to_not be nil
    end

    it 'should return a node to responds to :to_articulation correctly' do
      expect(res.to_articulation).to eq art
    end
  end
end
