require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Sequencer::NoteFIFO do
  describe '#initialize' do
    it 'should add the given notes to the FIFO' do
      notes = [Note.half, Note.quarter]
      fifo = Sequencer::NoteFIFO.new(notes)
      fifo.notes.should eq(notes)
      fifo.duration.should eq(Rational(3,4))
    end
  end

  describe '#empty?' do
    context 'FIFO does not have notes' do
      it 'should return true' do
        # initialized without notes
        Sequencer::NoteFIFO.new.empty?.should be_truthy

        # or removed later
        fifo = Sequencer::NoteFIFO.new
        fifo.remove_notes(fifo.duration)
        fifo.empty?.should be_truthy
      end
    end

    context 'FIFO has notes' do
      it 'should return false' do
        # initialized with notes
        notes = [Note.whole, Note.half, Note.quarter]
        Sequencer::NoteFIFO.new(notes).empty?.should be_falsey

        # or added later
        fifo = Sequencer::NoteFIFO.new
        fifo.add_notes(notes)
        fifo.empty?.should be_falsey
      end
    end
  end

  describe '#add_notes' do
    context 'given empty array' do
      before :all do
        @notes = [Note.whole, Note.half, Note.quarter]
        @fifo = Sequencer::NoteFIFO.new(@notes)
        @prev_duration = @fifo.duration
        @fifo.add_notes([])
      end

      it 'should not change the current note array' do
        @fifo.notes.should eq(@notes)
      end

      it 'should not change the duration' do
        @fifo.duration.should eq(@prev_duration)
      end
    end

    context 'given array of one note' do
      before :all do
        @notes = [Note.quarter, Note.half]
        @fifo = Sequencer::NoteFIFO.new(@notes)
        @prev_duration = @fifo.duration
        @new_note = Note.whole
        @fifo.add_notes([@new_note])
      end

      it 'should append the given note to the FIFO note array' do
        @fifo.notes.should eq(@notes + [@new_note])
      end

      it 'should increase the FIFO duration by the total duration of the given note' do
        @fifo.duration.should eq(@prev_duration + @new_note.duration)
      end
    end

    context 'given an array of more than one note' do
      before :all do
        @notes = [Note.quarter, Note.half]
        @fifo = Sequencer::NoteFIFO.new(@notes)
        @prev_duration = @fifo.duration
        @new_notes = [ Note.whole, Note.quarter ]
        @fifo.add_notes(@new_notes)
      end

      it 'should append the given notes to the FIFO note array' do
        @fifo.notes.should eq(@notes + @new_notes)
      end

      it 'should increase the FIFO duration by the total duration of the given notes' do
        add_dur = @new_notes.inject(0){|sum, n| sum + n.duration }
        @fifo.duration.should eq(@prev_duration + add_dur)
      end
    end
  end

  describe '#remove_notes' do
    before :each do
      @notes = [Note.whole, Note.half, Note.quarter]
      @fifo = Sequencer::NoteFIFO.new(@notes)
    end

    context 'given negative target duration' do
      it 'should raise ArgumentError' do
        expect { @fifo.remove_notes(-1) }.to raise_error(ArgumentError)
      end
    end

    context 'given target duration greater than FIFO duration' do
      it 'should raise ArgumentError' do
        expect { @fifo.remove_notes(@fifo.duration + 1) }.to raise_error(ArgumentError)
      end
    end

    context 'given target_duration of 0' do
      it 'should return an empty array and not affect FIFO' do
        removed_notes = @fifo.remove_notes(0)
        removed_notes.should be_empty
        @fifo.notes.should eq(@notes)
      end
    end

    context 'given target duration equal to FIFO duration' do
      it 'should empty FIFO and bring duration to 0' do
        @fifo.remove_notes(@fifo.duration)
        @fifo.empty?.should be_truthy
        @fifo.duration.should eq(0)
      end
    end

    context 'given positive target duration less than FIFO duration' do
      context 'target duration lands exactly on note boundary' do
        before :all do
          @notes = [Note.whole, Note.half, Note.quarter]
          @fifo = Sequencer::NoteFIFO.new(@notes)
          @prev_fifo_dur = @fifo.duration
          @target_dur = 1.5
        end

        it 'should reduce FIFO duration by the given target duration' do
          @fifo.remove_notes(@target_dur)
          @fifo.duration.should eq(@prev_fifo_dur - @target_dur)
        end

        it 'should remove notes from the front of the FIFO, totally in tact' do
          removed = @fifo.remove_notes(@target_dur)
          removed.should eq(@notes[0..1])
          @fifo.notes.should eq([@notes.last])
        end
      end

      context 'target duration lands somewhere during one of the notes' do
        before :each do
          @notes = [Note.whole, Note.half([Pitches::C4]), Note.quarter]
          @fifo = Sequencer::NoteFIFO.new(@notes)
          @prev_fifo_dur = @fifo.duration
          @target_dur = 1.25
        end

        it 'should reduce FIFO duration by the given target duration' do
          @fifo.remove_notes(@target_dur)
          @fifo.duration.should eq(@prev_fifo_dur - @target_dur)
        end

        it 'should remove notes from the front of the FIFO, dividing the last one into two tied notes' do
          expected_removed = [
            Note.whole,
            Note.quarter([Pitches::C4], links: { Pitches::C4 => Link::Tie.new })
          ]

          expected_remaining = [
            Note.quarter([Pitches::C4]),
            Note.quarter
          ]

          removed = @fifo.remove_notes(@target_dur)

          removed.should eq(expected_removed)
          @fifo.notes.should eq(expected_remaining)
        end
      end
    end
  end
end
