require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

NOTE_PARSER = Parsing::NoteParser.new

describe Parsing::NoteNode do
  context 'rest note' do  
    {
      '/2' => Note.new(Rational(1,2)),
      '4/2' => Note.new(Rational(4,2)),
      '28' => Note.new(Rational(28,1)),
      '56/33' => Note.new(Rational(56,33)),
    }.each do |str,tgt|
      res = NOTE_PARSER.parse(str)
      context str do
        it 'should parse as NoteNode' do
          res.should be_a Parsing::NoteNode
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
        it 'should parse as `Node' do
          res.should be_a Parsing::NoteNode
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
        it 'should parse as NoteNode' do
          res.should be_a Parsing::NoteNode
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

  context 'with marks' do
    [[BEGIN_SLUR],[BEGIN_SLUR, BEGIN_TRIPLET],[BEGIN_TRIPLET]].each do |begin_marks|
      begin_marks_str = begin_marks.map {|m| m.to_s}.join
      [[END_SLUR],[END_SLUR, END_TRIPLET],[END_TRIPLET]].each do |end_marks|
        end_marks_str = end_marks.map {|m| m.to_s}.join
        describe '#to_note' do
          it 'should produce a Note with marks set correctly' do
            str = "#{begin_marks_str}/4Bb2#{end_marks_str}"
            n = NOTE_PARSER.parse(str).to_note
            n.marks.should eq(begin_marks+end_marks)
          end
        end
      end
    end
  end

  context 'without marks' do
    it 'should produce a Note with marks set to []' do
      str = "/4Bb2"
      n = NOTE_PARSER.parse(str).to_note
      n.marks.should eq([])
    end
  end
end
