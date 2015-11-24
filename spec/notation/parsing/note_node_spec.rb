require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

NOTE_PARSER = Parsing::NoteParser.new

describe Parsing::SingleNoteNode do
  context 'rest note' do  
    {
      '/2' => Note.new(Rational(1,2)),
      '4/2' => Note.new(Rational(4,2)),
      '28' => Note.new(Rational(28,1)),
      '56/33' => Note.new(Rational(56,33)),
    }.each do |str,tgt|
      res = NOTE_PARSER.parse(str)
      context str do
        it 'should parse as SingleNoteNode' do
          res.should be_a Parsing::SingleNoteNode
        end
  
        describe '#to_note' do
          n = res.to_note
          it 'should produce a Note' do
            n.should be_a Note
          end
          
          it 'should produce value matching input str' do
            n.should eq tgt
          end
        end
      end
    end
  end

  context 'monophonic note' do
    {
      '/2C2~' => Note.new(Rational(1,2),[C2], links: { C2 => Link::Tie.new}),
      '4/2D#6.' => Note.new(Rational(4,2),[Eb6],articulation:STACCATO),
      '28Eb7_' => Note.new(Rational(28,1),[Eb7],articulation:PORTATO),
      "56/33B1!" => Note.new(Rational(56,33),[B1],articulation:STACCATISSIMO),
    }.each do |str,tgt|
      res = NOTE_PARSER.parse(str)
      
      context str do
        it 'should parse as SingleNoteNode' do
          res.should be_a Parsing::SingleNoteNode
        end
  
        describe '#to_note' do
          n = res.to_note
          it 'should produce a Note' do
            n.should be_a Note
          end
          
          it 'should produce value matching input str' do
            n.should eq tgt
          end
        end
      end
    end
  end

  context 'polyphonic note' do
    {
      '/2C2,D2,E2>' => Note.new(Rational(1,2),[C2,D2,E2],articulation: Articulations::ACCENT),
      '/2C2,D2,E2^' => Note.new(Rational(1,2),[C2,D2,E2],articulation: Articulations::MARCATO),
      '4/2D#6,G4.' => Note.new(Rational(4,2),[Eb6,G4], articulation: Articulations::STACCATO),
      '28Eb7,D7,G7-' => Note.new(Rational(28,1),[Eb7,D7,G7], articulation: Articulations::TENUTO),
      '56/33B1,B2,B3,B4,B5_' => Note.new(Rational(56,33),[B1,B2,B3,B4,B5], articulation: Articulations::PORTATO),
    }.each do |str,tgt|
      res = NOTE_PARSER.parse(str)
      context str do
        it 'should parse as SingleNoteNode' do
          res.should be_a Parsing::SingleNoteNode
        end
  
        describe '#to_note' do
          n = res.to_note

          it 'should produce a Note' do
            n.should be_a Note
          end
          
          it 'should produce value matching input str' do
            n.should eq tgt
          end
        end
      end
    end
  end

  context 'with slur mark' do
    [ SlurMarks::BEGIN_SLUR, SlurMarks::END_SLUR ].each do |slur_mark|
      describe '#to_note' do
        it 'should produce a Note with slur mark set correctly' do
          str = "/4Bb2#{SLUR_MARK_SYMBOLS[slur_mark]}"
          n = NOTE_PARSER.parse(str).to_note
          n.slur_mark.should eq(slur_mark)
        end
      end
    end
  end

  context 'without slur mark' do
    it 'should produce a Note with slur mark set to NONE' do
      str = "/4Bb2"
      n = NOTE_PARSER.parse(str).to_note
      n.slur_mark.should eq(SlurMarks::NONE)      
    end
  end
end
