require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

describe Parsing::PositiveFloatParser do
  parser = Parsing::PositiveFloatParser.new

  ["2e2","1.0","0.50","05.003e-10","1.555e+2","3.443214","0.001","0000.0030000"].each do |str|
    res = parser.parse(str)
    f = str.to_f

    it "should parse '#{str}'" do
      expect(res).to_not be nil
    end

    it 'should return node that is convertible to float using #to_f method' do
      expect(res.to_f).to eq(f)
    end

    it 'should return node that is convertible to float using #to_num method' do
      expect(res.to_num).to eq(f)
    end
  end

  ["-2.0","-1.55e-2","0.0","0e1"].each do |str|
    it "should not parse '#{str}'" do
      expect(parser).to_not parse(str)
    end
  end
end
