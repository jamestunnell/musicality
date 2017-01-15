require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Parsing::NumDenNode do
  dur_parser = Parsing::DurationParser.new

  {
    '1/2' => Rational(1,2),
    '5/100' => Rational(5,100),
    '007/777' => Rational(7,777)
  }.each do |str,tgt|
    res = dur_parser.parse(str)
    context str do
      it 'should parse as NumDenNode' do
        expect(res).to be_a Parsing::NumDenNode
      end

      describe '#to_r' do
        r = res.to_r
        it 'should produce a Rational' do
          expect(r).to be_a Rational
        end

        it 'should produce value matching input str' do
          expect(r).to eq tgt
        end
      end
    end
  end
end

describe Parsing::NumOnlyNode do
  dur_parser = Parsing::DurationParser.new
    {
    '1/' => Rational(1,1),
    '5' => Rational(5,1),
    '007/' => Rational(7,1)
  }.each do |str,tgt|
    res = dur_parser.parse(str)
    context str do
      it 'should parse as NumOnlyNode' do
        expect(res).to be_a Parsing::NumOnlyNode
      end

      describe '#to_r' do
        r = res.to_r
        it 'should produce a Rational' do
          expect(r).to be_a Rational
        end

        it 'should produce value matching input str' do
          expect(r).to eq tgt
        end
      end
    end
  end
end

describe Parsing::DenOnlyNode do
  dur_parser = Parsing::DurationParser.new
  {
    '/2' => Rational(1,2),
    '/100' => Rational(1,100),
    '/777' => Rational(1,777)
  }.each do |str,tgt|
    res = dur_parser.parse(str)
    context str do
      it 'should parse as DenOnlyNode' do
        expect(res).to be_a Parsing::DenOnlyNode
      end

      describe '#to_r' do
        r = res.to_r
        it 'should produce a Rational' do
          expect(r).to be_a Rational
        end

        it 'should produce value matching input str' do
          expect(r).to eq tgt
        end
      end
    end
  end
end
