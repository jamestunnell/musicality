require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Parsing::PitchNode do
  parser = Parsing::PitchParser.new
  
  {
    'C4' => C4,
    'Db2' => Db2,
    'C#2' => Db2,
    'F7' => F7,
    'B1' => B1,
    "Bb22" => Pitch.new(octave: 22, semitone: 10),
    "G2235" => Pitch.new(octave: 2235, semitone: 7),
    "G2+11" => G2.transpose(0.11),
    "G2-11" => G2.transpose(-0.11),
    "A2-11301" => A2.transpose(-113.01),
    "B5+881" => B5.transpose(8.81),
  }.each do |str,tgt|
    res = parser.parse(str)
    context str do
      it 'should parse as PitchNode' do
        res.should be_a Parsing::PitchNode
      end
      
      describe '#to_pitch' do
        p = res.to_pitch
        it 'should produce a Pitch object' do
          p.should be_a Pitch
        end
        
        it 'should produce pitch matching input str' do
          p.should eq tgt
        end
      end
    end
  end  
end
