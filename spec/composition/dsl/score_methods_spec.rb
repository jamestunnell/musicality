require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Score do
  describe '#notes' do
    before :all do
      @equal_duration_note_sets = [
        [ Note.quarter, Note.half ],
        [ Note.eighth, Note.half, Note.eighth ],
        "/2 /12 /12 /12".to_notes,
      ]
    end

    context 'given two parts' do
      before :all do
        @notes_a = "/4C2 /4Bb2 /2D4".to_notes
        @notes_b = "/8 /8F3 3/4D2".to_notes
      end

      context 'neither part in score already' do
        it 'should create both parts with given notes and add to score' do
          s = Score::Timed.new
          s.notes("A" => @notes_a, "B" => @notes_b)
          expect(s.parts).to include("A")
          expect(s.parts).to include("B")
          expect(s.parts["A"].notes).to eq(@notes_a)
          expect(s.parts["B"].notes).to eq(@notes_b)
        end
      end

      context 'both parts in score already' do
        it 'should add onto part notes' do
          s = Score::Timed.new(parts: { 
            "A" => Part.new(Dynamics::MP),
            "B" => Part.new(Dynamics::MF)
          })
          s.notes("A" => @notes_a, "B" => @notes_b)
          expect(s.parts["A"].notes).to eq(@notes_a)
          expect(s.parts["B"].notes).to eq(@notes_b)
        end
      end

      context 'one part in score already' do
        it 'should create the other part with an initial rest and add to score' do
          first_note_a = Note.whole(C2)
          s = Score::Timed.new(parts: { 
            "A" => Part.new(Dynamics::MP, notes: [ first_note_a ]),
          })
          s.notes("A" => @notes_a, "B" => @notes_b)
          expect(s.parts["A"].notes).to eq([first_note_a] + @notes_a)
          expect(s.parts["B"].notes).to eq([Note.whole] + @notes_b)
        end
      end

      context 'given equal duration note sets' do
        it 'should not raise DurationMismatchError' do
          @equal_duration_note_sets.combination(2).each do |note_sets|
            s = Score::Timed.new
            expect { s.notes("A" => note_sets[0], "B" => note_sets[1]) }.to_not raise_error
          end
        end
      end

      context 'given different duration note sets' do
        it 'should raise DurationMismatchError' do
          note_set_a = "/4 /4 /8".to_notes
          note_set_b = "/4 /4 /8 /16".to_notes
          s = Score::Timed.new
          expect { s.notes("A" => note_set_a, "B" => note_set_b) }.to raise_error(DurationMismatchError)
        end
      end
    end
  end
end
