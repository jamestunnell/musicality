require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe ScoreCollator do
  describe '#collate_parts' do
    before :all do
      @part = Part.new(Dynamics::FF,
        notes: [ Note.quarter([C2]),
          Note.half([D2]),
          Note.half([E2])
      ])
    end

    context 'first note starts before the segment start' do
      context 'first note ends right at segment start' do
        it 'should not be included in the part' do
          score = Score::Tempo.new(120, start_meter: FOUR_FOUR,
            parts: {1 => @part},
            program: ["1/4".to_r..."5/4".to_r])
          collator = ScoreCollator.new(score)
          parts = collator.collate_parts
          notes = parts[1].notes
          expect(notes.size).to eq(@part.notes.size - 1)
          expect(notes[0].pitches[0]).to eq D2
          expect(notes[1].pitches[0]).to eq E2
        end
      end

      context 'first note ends after segment start' do
        it 'should not be included in the part, and a rest is inserted' do
          score = Score::Tempo.new(120, start_meter: FOUR_FOUR,
            parts: {1 => @part},
            program: ["1/8".to_r..."5/4".to_r])
          collator = ScoreCollator.new(score)
          parts = collator.collate_parts
          notes = parts[1].notes
          expect(notes.size).to eq(@part.notes.size)
          expect(notes[0].pitches).to be_empty
          expect(notes[0].duration).to eq "1/8".to_r
          expect(notes[1].pitches[0]).to eq D2
          expect(notes[2].pitches[0]).to eq E2
        end
      end
    end

    context 'first note starts at segment start' do
      context 'last note starts at program end' do
        it 'should not be included in the part' do
          score = Score::Tempo.new(120, start_meter: FOUR_FOUR,
            parts: {1 => @part},
            program: [0.to_r..."3/4".to_r])
          collator = ScoreCollator.new(score)
          parts = collator.collate_parts
          notes = parts[1].notes
          expect(notes.size).to eq(@part.notes.size - 1)
        end
      end

      context 'last note start before program end, but lasts until after' do
        it 'should be included in the part, but truncated' do
          score = Score::Tempo.new(120, start_meter: FOUR_FOUR,
            parts: {1 => @part},
            program: [0.to_r...1.to_r])
          collator = ScoreCollator.new(score)
          parts = collator.collate_parts
          notes = parts[1].notes
          expect(notes.size).to eq(@part.notes.size)
          expect(notes[-1].duration).to eq("1/4".to_r)
        end
      end

      context 'last note ends before program segment end' do
        it 'should insert a rest between last note end and segment end' do
          score = Score::Tempo.new(120, start_meter: FOUR_FOUR,
            parts: {1 => @part},
            program: [0.to_r..."6/4".to_r])
          collator = ScoreCollator.new(score)
          parts = collator.collate_parts
          notes = parts[1].notes
          expect(notes.size).to eq(@part.notes.size + 1)
          expect(notes[-1].pitches).to be_empty
          expect(notes[-1].duration).to eq("1/4".to_r)
        end
      end
    end

    context 'part contains trimmed gradual changes' do
      it 'should exclude the change when it is not at all in a program segment' do
        score = Score::Tempo.new(120, start_meter: FOUR_FOUR,
          parts: { 1 => Part.new(Dynamics::FF, dynamic_changes: {
            2 => Change::Gradual.linear(Dynamics::PP,5).trim(1,0)
          }) },
          program: [7...9]
        )
        collator = ScoreCollator.new(score)
        parts = collator.collate_parts
        dcs = parts[1].dynamic_changes
        expect(dcs.size).to eq(0)
        expect(parts[1].start_dynamic).to be_within(1e-5).of(Dynamics::PP)

        score.program = [0...1]
        collator = ScoreCollator.new(score)
        parts = collator.collate_parts
        dcs = parts[1].dynamic_changes
        expect(dcs.size).to eq(0)
        expect(parts[1].start_dynamic).to be_within(1e-5).of(Dynamics::FF)
      end

      it 'should trim the change further if needed' do
        score = Score::Tempo.new(120, start_meter: FOUR_FOUR,
          parts: { 1 => Part.new(Dynamics::FF, dynamic_changes: {
            2 => Change::Gradual.linear(Dynamics::PP,5).trim(1,1)
          }) },
          program: [3...4]
        )
        collator = ScoreCollator.new(score)
        parts = collator.collate_parts
        dcs = parts[1].dynamic_changes
        expect(dcs.size).to eq(1)
        expect(dcs[0.to_r]).to eq(Change::Gradual.linear(Dynamics::PP,5).trim(2,2))
      end
    end

    it 'should preserve links' do
      notes = Note.split_parse("1Db4;Bb4")
      score = Score::Tempo.new(
        120, start_meter: FOUR_FOUR,
        parts: { "lead" => Part.new(Dynamics::MP, notes: notes) },
        program: [0..1,0..1],
      )
      collator = ScoreCollator.new(score)
      parts = collator.collate_parts

      notes = parts["lead"].notes
      expect(notes.size).to eq 2
      notes.each do |note|
        expect(note.links).to have_key(Db4)
        expect(note.links[Db4]).to be_a Link::Glissando
      end
    end
  end

  describe '#collate_tempo_changes' do
    before :all do
      @change0 = Change::Immediate.new(120)
      @change1 = Change::Immediate.new(200)
      @change2 = Change::Gradual.linear(100,1)
    end

    context 'tempo change starts at end of program segment' do
      it 'should not be included in the tempo changes' do
        score = Score::Tempo.new(120, start_meter: FOUR_FOUR, tempo_changes: {
          1 => @change1, 2 => @change2 }, program: [0...2])
        collator = ScoreCollator.new(score)
        st, tcs = collator.collate_tempo_changes
        expect(tcs.size).to eq 1
        expect(tcs[1.to_r]).to eq @change1
      end
    end

    context 'tempo change starts and ends before segment' do
      before :all do
        score = Score::Tempo.new(120, start_meter: FOUR_FOUR, tempo_changes: {
          2 => @change2 }, program: [4..5])
        collator = ScoreCollator.new(score)
        @st, @tcs = collator.collate_tempo_changes
      end

      it 'should not be included in the tempo changes' do
        expect(@tcs.size).to eq 0
      end

      it 'should be used as start tempo' do
        expect(@st).to be_within(1e-5).of @change2.end_value
      end
    end

    context 'tempo change starts before segment, but ends during segment' do
      it 'should e included in the tempo changes, but truncated' do
        score = Score::Tempo.new(120, start_meter: FOUR_FOUR, tempo_changes: {
          1.5.to_r => @change2 }, program: [2..4])
        collator = ScoreCollator.new(score)
        st, tcs = collator.collate_tempo_changes
        expect(tcs.size).to eq 1
        expect(tcs[0.to_r]).to be_a Change::Gradual::Trimmed
        expect(tcs[0.to_r].end_value).to eq @change2.end_value
        expect(tcs[0.to_r].remaining).to eq(0.5)
      end
    end

    context 'tempo change starts during segment, lasts until after' do
      it 'should be included in the tempo changes, but truncated' do
        score = Score::Tempo.new(120, start_meter: FOUR_FOUR, tempo_changes: {
          1 => @change1, 2 => @change2 }, program: [0..2.5])
        collator = ScoreCollator.new(score)
        st, tcs = collator.collate_tempo_changes
        expect(tcs.size).to eq 2
        expect(tcs[1.to_r]).to eq @change1
        expect(tcs[2.to_r]).to be_a Change::Gradual::Trimmed
        expect(tcs[2.to_r].end_value).to eq @change2.end_value
        expect(tcs[2.to_r].remaining).to eq(0.5)
      end
    end
  end

  describe '#collate_meter_changes' do
    it 'should behave just as #collate_tempo_changes' do
      change0 = Change::Immediate.new(FOUR_FOUR)
      change1 = Change::Immediate.new(THREE_FOUR)
      change2 = Change::Immediate.new(SIX_EIGHT)
      score = Score::Tempo.new(120, start_meter: FOUR_FOUR, meter_changes: {
        1 => change1, 2 => change2 }, program: [0...2])
      collator = ScoreCollator.new(score)
      sm, mcs = collator.collate_meter_changes
      expect(mcs.size).to eq 1
      expect(mcs[1.to_r]).to eq change1
    end
  end
end
