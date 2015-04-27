require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Parsing::LinkNode do
  parser = Parsing::LinkParser.new
  
  {
    LINK_SYMBOLS[Links::TIE] => Link::Tie.new,
    (LINK_SYMBOLS[Links::GLISSANDO] + Db2.to_s) => Link::Glissando.new(Db2),
    (LINK_SYMBOLS[Links::PORTAMENTO] + Db2.to_s) => Link::Portamento.new(Db2),
  }.each do |str,tgt|
    res = parser.parse(str)
    context str do
      it 'should parse as LinkNode' do
        res.should be_a Parsing::LinkNode
      end
      
      describe '#to_pitch' do
        l = res.to_link
        it 'should produce a Link object' do
          l.should be_a Link
        end
        
        it 'should produce pitch matching input str' do
          l.should eq tgt
        end
      end
    end
  end  
end
