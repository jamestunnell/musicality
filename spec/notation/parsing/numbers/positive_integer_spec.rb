require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe Parsing::PositiveIntegerParser do
  parser = Parsing::PositiveIntegerParser.new

  ["1","50","05","502530"].each do |str|
    res = parser.parse(str)
    i = str.to_i

    it "should parse '#{str}'" do
      expect(res).to_not be nil
    end

    it 'should return node that is convertible to integer using #to_i method' do
      expect(res.to_i).to eq(i)
    end

    it 'should return node that is convertible to integer using #to_num method' do
      expect(res.to_num).to eq(i)
    end
  end

  ["0"].each do |str|
    it "should not parse '#{str}'" do
      expect(parser).to_not parse(str)
    end
  end
end
