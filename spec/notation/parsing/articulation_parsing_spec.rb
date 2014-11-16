require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Parsing::ArticulationParser do
  parser = Parsing::ArticulationParser.new
  
  {
    '=' => SLUR,
    '|' => LEGATO,
    '_' => TENUTO,
    '%' => PORTATO,
    '.' => STACCATO,
    "'" => STACCATISSIMO
  }.each do |str,art|
    res = parser.parse(str)
    it "should parse '#{str}'" do
      res.should_not be nil
    end
    
    it 'should return a node to responds to :to_articulation correctly' do
      res.to_articulation.should eq art
    end
  end
end
