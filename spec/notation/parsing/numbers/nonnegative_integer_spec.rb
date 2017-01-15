require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe Parsing::NonnegativeIntegerParser do
  parser = Parsing::NonnegativeIntegerParser.new

  ["1","50","05","502530","0"].each do |str|
    it "should parse '#{str}'" do
      expect(parser.parse(str)).to_not be nil
    end
  end

  it 'should not parse an empty string' do
    expect(parser.parse("")).to be nil
  end
end
