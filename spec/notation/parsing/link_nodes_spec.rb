require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Parsing::LinkNode do
  parser = Parsing::LinkParser.new
  
  {
    '=C4' => Link::Slur.new(C4),
    '/Db2' => Link::Portamento.new(Db2),
    '~C#2' => Link::Glissando.new(Db2),
    '|Db2' => Link::Legato.new(Db2),
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
