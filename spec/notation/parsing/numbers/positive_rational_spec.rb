require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe Parsing::PositiveRationalParser do
  parser = Parsing::PositiveRationalParser.new

  ["1/2","50/50","050/003","502530/1","01/1"].each do |str|
    res = parser.parse(str)
    r = str.to_r

    it "should parse '#{str}'" do
      expect(res).to_not be nil
    end

    it 'should return node that is convertible to rational using #to_r method' do
      expect(res.to_r).to eq(r)
    end

    it 'should return node that is convertible to rational using #to_num method' do
      expect(res.to_num).to eq(r)
    end
  end

  ["0/0","0/10","0000/1"].each do |str|
    it "should not parse '#{str}'" do
      expect(parser).to_not parse(str)
    end
  end
end
