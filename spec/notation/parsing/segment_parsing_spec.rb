require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Parsing::SegmentParser do
  parser = Parsing::SegmentParser.new

  cases = {
    "ints" => ["0...4",0...4],
    "plain floats" => ["0.0..4.0",0.0...4.0],
    "sci floats" => ["1.3e-10...5",1.3e-10...5],
    "int/float" => ["45..46.5",45...46.5],
    "float/int" => ["4.5...5",4.5...5],
    "rationals" => ["2/3..3/2",Rational(2,3)...Rational(3,2)],
    "float/rational" => ["3.5..10/6",3.5...Rational(10,6)]
  }.each do |descr,str_tgt|
    context descr do
      str,tgt = str_tgt
      res = parser.parse(str)
      it 'should parse' do
        res.should_not be nil
      end
      
      it 'should return node that converts to exclusive range via #to_range' do
        res.to_range.should eq tgt
      end
    end
  end
end
