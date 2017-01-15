require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Parsing::MeterParser do
  parser = Parsing::MeterParser.new

  {
    '4/4' => FOUR_FOUR,
    '2*3/8' => SIX_EIGHT,
    '12/3' => Meter.new(12,"1/3".to_r),
    '3*3/8' => Meter.new(3,"3/8".to_r),
    '3/4' => THREE_FOUR
  }.each do |str,met|
    res = parser.parse(str)

    it "should parse #{str}" do
      expect(res).to_not be nil
    end

    it 'should produce node that properly converts to meter' do
      expect(res.to_meter).to eq met
    end
  end
end
