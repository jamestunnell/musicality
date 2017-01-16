require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Sequencer do
  describe '#next_part_notes' do
    context '1 part with NoteArray sequenceable' do
      describe 'given target duration that occurs in between note boundaries' do
        it 'should return the part notes with the last note being shortened but tied' do
          @seq = Sequencer.new("X" => NoteArray.new([Note.half(Pitches::G2)]))
          expect(@seq.next_part_notes(Rational(1,4))).to eq(
            "X" => [ Note.quarter(Pitches::G2).tie_to(Pitches::G2) ]
          )
        end
      end
    end

    context '2 parts (X,Y) with NoteArray sequenceables, X twice as long as Y' do
      before :each do
        @x_note_array = NoteArray.new([ Note.quarter(Pitches::D3), Note.quarter(Pitches::C3),
                          Note.quarter(Pitches::G3), Note.quarter(Pitches::F3) ])
        @y_note_array = NoteArray.new([ Note.half(Pitches::A3) ])
        @seq = Sequencer.new("X" => @x_note_array, "Y" => @y_note_array)
      end

      context 'target duration equal to X duration' do
        context 'next_part_notes not called yet before' do
          it 'should produce all the notes for X and double the notes for Y' do
            expect(@seq.next_part_notes(@x_note_array.duration)).to eq(
              {"X" => @x_note_array.notes, "Y" => @y_note_array.notes*2}
            )
          end
        end

        context 'next_part_notes already called once with target duration equal to X duration' do
          it 'should produce all the notes for X and double the notes for Y' do
            @seq.next_part_notes(@x_note_array.duration)
            expect(@seq.next_part_notes(@x_note_array.duration)).to eq(
              {"X" => @x_note_array.notes, "Y" => @y_note_array.notes*2}
            )
          end
        end
      end

      context 'target duration equal to Y duration' do
        context 'next_part_notes not called yet before' do
          it 'should return first half of X notes and all of Y' do
            expect(@seq.next_part_notes(Rational(@x_note_array.duration,2))).to eq(
              { "X" => @x_note_array.notes[0..1], "Y" => @y_note_array.notes }
            )
          end
        end

        context 'next_part_notes already called once with half of X duration' do
          it 'should return last half of X notes and all of Y' do
            @seq.next_part_notes(Rational(@x_note_array.duration,2))
            expect(@seq.next_part_notes(Rational(@x_note_array.duration,2))).to eq(
              { "X" => @x_note_array.notes[2..3], "Y" => @y_note_array.notes }
            )
          end
        end
      end
    end
  end

  describe '#reset' do
    it 'should reset each sequenceable' do
      sequencable1 = instance_double("NoteArray")
      sequencable2 = instance_double("NoteArray")

      expect(sequencable1).to receive(:reset)
      expect(sequencable2).to receive(:reset)

      seq = Sequencer.new("X" => sequencable1, "Y" => sequencable2)
      seq.reset
    end
  end
end
