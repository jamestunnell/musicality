require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe 'make_note' do
  it 'should return a Note' do
    expect(make_note(0.3,C3)).to be_a Note
  end

  context 'given single pitch' do
    it 'should have the given duration and pitch' do
      n = make_note(0.3,C3)
      expect(n.duration).to eq(0.3)
      expect(n.pitches).to eq([C3])
    end
  end

  context 'given pitch array' do
    it 'should have the given duration and pitches' do
      n = make_note(0.2,[C3,E3,Ab3])
      expect(n.duration).to eq(0.2)
      expect(n.pitches).to eq([C3,E3,Ab3])
    end
  end

  context 'given negative duration' do
    it 'should have duration with same magnitude' do
      expect(make_note(-0.3,C3).duration).to eq(0.3)
    end

    it 'should make a rest note (no pitches)' do
      expect(make_note(-0.3,[C3,E3]).pitches).to be_empty
    end
  end
end

describe 'make_notes' do
  context 'given empty rhythm or pitch_groups' do
    it 'should raise EmptyError' do
      expect do
        make_notes([],[A3,B3,C3])
      end.to raise_error(EmptyError)
      expect do
        make_notes([2,2],[])
      end.to raise_error(EmptyError)
    end
  end

  context 'given equal length rhtyhm and pitch_groups' do
    it 'should produce same number of notes as both' do
      expect(make_notes([2,2,5],[A1,B1,C1]).size).to eq(3)
    end
  end

  context 'given longer rhythm than pitch_groups' do
    before :all do
      @rhythm = [4,3,3,1]
      @pitch_groups = [[C1],[E2,G2]]
      @notes = make_notes(@rhythm,@pitch_groups)
    end

    it 'should produce same number of notes as rhythm.size' do
      expect(@notes.size).to eq(@rhythm.size)
    end

    it 'should follow entire rhythm once' do
      expect(@notes.map {|n| n.duration}).to eq(@rhythm)
    end

    it 'should cycle through pitch groups as necesary' do
      expect(@notes.map {|n| n.pitches}).to eq(@pitch_groups*2)
    end
  end

  context 'given longer pitch_groups than rhythm' do
    before :all do
      @rhythm = [4,3,1]
      @pitch_groups = [[C1],[E2,G2],[F5,G5,A5],[F4],[Eb4],[G4]]
      @notes = make_notes(@rhythm,@pitch_groups)
    end

    it 'should produce same number of notes as pitch_groups.size' do
      expect(@notes.size).to eq(@pitch_groups.size)
    end

    it 'should follow entire pitch_groups once' do
      expect(@notes.map {|n| n.pitches}).to eq(@pitch_groups)
    end

    it 'should cycle through rhythm as necesary' do
      expect(@notes.map {|n| n.duration}).to eq(@rhythm*2)
    end
  end

  context 'given same-length pitch_groups and rhythm' do
    before :all do
      @rhythm = [4,3,1]
      @pitch_groups = [[F4],[Eb4],[G4]]
      @notes = make_notes(@rhythm,@pitch_groups)
    end

    it 'should produce same number of notes as rhythm.size and pitch_groups.size' do
      expect(@notes.size).to eq(@pitch_groups.size)
      expect(@notes.size).to eq(@rhythm.size)
    end

    it 'should follow entire rhythm once' do
      expect(@notes.map {|n| n.pitches}).to eq(@pitch_groups)
    end

    it 'should follow entire pitch groups once' do
      expect(@notes.map {|n| n.duration}).to eq(@rhythm)
    end
  end
end
