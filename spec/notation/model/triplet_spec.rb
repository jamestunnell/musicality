require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Triplet do
  describe '.new' do
    context 'given notes not all same duration' do
      it 'should raise DurationMismatchError' do
        notes = Note.quarter(C4), Note.quarter(D4), Note.eighth(D4)
        expect { Triplet.new(*notes) }.to raise_error(DurationMismatchError)
      end
    end

    before :all do
      @notes = q(C4,E4,F4)
      @t = Triplet.new(*@notes)
    end

    context 'given notes with same duration' do
      it 'should have duration that is 2/3 of what normal total would be' do
        @t.duration.should eq("1/2".to_r)
      end
    end

    describe '#first_note' do
      it 'should return the first note in the triplet' do
        @t.first_note.should eq(@notes[0])
      end
    end

    describe '#second_note' do
      it 'should return the second note in the triplet' do
        @t.second_note.should eq(@notes[1])
      end
    end

    describe '#third_note' do
      it 'should return the third note in the triplet' do
        @t.third_note.should eq(@notes[2])
      end
    end

    describe '#==' do
      it 'should return true if two triplets have all the same notes' do
        Triplet.new(*q(D3,E3,F3)).should eq(Triplet.new(*q(D3,E3,F3)))
      end
    end

    describe '#clone' do
      it 'should return an new object, equal to the original' do
        t2 = @t.clone
        t2.should eq(@t)
        t2.should_not be(@t)
      end
    end

    describe '#transpose' do
      it 'should return a new Triplet, where the note pitches are all transposed' do
        t2 = @t.transpose(2)
        t2.should eq(Triplet.new(*transpose(@notes,2)))
        t2.should_not be(@t)
      end
    end

    describe '#transpose!' do
      it 'should transpose the notes of the triplet object, in place' do
        t2 = @t.clone
        t2.transpose!(2)
        t2.should eq(@t.transpose(2))
      end
    end

    describe '#duration=' do
      it 'should resize the triplet note durations to each be half the given duration' do
        t2 = @t.clone
        t2.duration = "1/4".to_r
        t2.first_note.duration.should eq("1/8".to_r)
        t2.second_note.duration.should eq("1/8".to_r)
        t2.third_note.duration.should eq("1/8".to_r)
      end
    end

    describe '#resize' do
      it 'should return a new triplet with duration changed to given amount' do
        new_dur = "1/4".to_r
        t2 = @t.resize(new_dur)
        t3 = @t.clone
        t3.duration = new_dur
        t2.should eq t3
      end
    end

    describe '#to_s' do
      it "should return same strings as for triplet notes, but connected by #{TRIPLET_CONNECTOR}" do
        @t.to_s.split(TRIPLET_CONNECTOR).should eq(
          [@t.first_note.to_s, @t.second_note.to_s, @t.third_note.to_s]
        )
      end
    end

    describe '#expand' do
      it 'should return array of three notes, each with one third of the total triplet duration' do
        @t.expand.each do |note|
          note.duration.should eq(@t.duration/3)
        end
      end
    end

    describe 'pitches' do
      it 'should return all the (uniq) pitches from all the triplet notes' do
        Triplet.new(*q([C3,E3,G3],A4,[F4,G4])).pitches.should eq(
          [C3,E3,G3,F4,G4,A4]
        )
      end
    end
  end
end
