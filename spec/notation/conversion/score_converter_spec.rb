require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe ScoreConverter do
  describe '#initialize' do
    context 'current score is invalid' do
      it 'should raise NotValidError' do
        score = Score::Tempo.new(120, start_meter: 1)
        expect { ScoreConverter.new(score,200) }.to raise_error(NotValidError)
      end
    end
  end

  describe '#convert_parts' do
    before :each do
      @changeA = Change::Immediate.new(Dynamics::PP)
      @changeB = Change::Gradual.linear(Dynamics::F, 2)
      @score = Score::Tempo.new(120, start_meter: FOUR_FOUR,
        parts: {"simple" => Part.new(Dynamics::MP, dynamic_changes: { 1 => @changeA, 3 => @changeB })}
      )
    end

    it 'should return Hash with original part names' do
      parts = ScoreConverter.new(@score,200).convert_parts
      expect(parts).to be_a Hash
      expect(parts.keys.sort).to eq(@score.parts.keys.sort)
    end

    it 'should convert part dynamic change offsets from note-based to time-based' do
      parts = ScoreConverter.new(@score,200).convert_parts
      expect(parts).to have_key("simple")
      part = parts["simple"]
      expect(part.dynamic_changes.keys.sort).to eq([2,6])
      change = part.dynamic_changes[2.0]
      expect(change.end_value).to eq(@changeA.end_value)
      change = part.dynamic_changes[6.0]
      expect(change.end_value).to eq(@changeB.end_value)
      expect(change.duration).to eq(4)

      @score.start_meter = THREE_FOUR
      parts = ScoreConverter.new(@score,200).convert_parts
      expect(parts).to have_key("simple")
      part = parts["simple"]
      expect(part.dynamic_changes.keys.sort).to eq([2,6])
      change = part.dynamic_changes[2.0]
      expect(change.end_value).to eq(@changeA.end_value)
      expect(change.duration).to eq(0)
      change = part.dynamic_changes[6.0]
      expect(change.end_value).to eq(@changeB.end_value)
      expect(change.duration).to eq(4)
    end

    context 'gradual changes with positive elapsed and/or remaining' do
     it 'should change elapsed and remaining so they reflect time-based offsets' do
       score = Score::Tempo.new(120, start_meter: THREE_FOUR, parts: {
         "abc" => Part.new(Dynamics::P, dynamic_changes: {
             2 => Change::Gradual.linear(Dynamics::F,2).to_trimmed(1, 3),
             7 => Change::Gradual.linear(Dynamics::F,1).to_trimmed(4, 5)
         })
       })
       converter = ScoreConverter.new(score, 200)
       parts = converter.convert_parts
       dcs = parts["abc"].dynamic_changes

       expect(dcs.keys).to eq([4, 14])
       expect(dcs[4.0]).to eq(Change::Gradual.linear(Dynamics::F,4).to_trimmed(2,6))
       expect(dcs[14.0]).to eq(Change::Gradual.linear(Dynamics::F,2).to_trimmed(8,10))
     end
    end
  end

  describe '#convert_program' do
    before :each do
      @prog = [0...4,2...5]
      @score = Score::Tempo.new(120, start_meter: FOUR_FOUR, program: @prog)
      @converter = ScoreConverter.new(@score,200)
    end

    it 'shuld return array with same size' do
      prog = @converter.convert_program
      expect(prog).to be_a Array
      expect(prog.size).to eq(@score.program.size)
    end

    it 'should convert program segments offsets from note-based to time-based' do
      prog = ScoreConverter.new(@score,200).convert_program
      expect(prog.size).to eq(2)
      expect(prog[0].first).to eq(0)
      expect(prog[0].last).to eq(8)
      expect(prog[1].first).to eq(4)
      expect(prog[1].last).to eq(10)

      @score.start_meter = THREE_FOUR
      prog = ScoreConverter.new(@score,200).convert_program
      expect(prog.size).to eq(2)
      expect(prog[0].first).to eq(0)
      expect(prog[0].last).to eq(8)
      expect(prog[1].first).to eq(4)
      expect(prog[1].last).to eq(10)
    end
  end

  describe '#convert_score' do
    it 'should return a timed score' do
      score = Score::Tempo.new(120, start_meter: FOUR_FOUR)
      converter = ScoreConverter.new(score,200)
      expect(converter.convert_score).to be_a Score::Timed
    end

    it 'should use output from convert_program' do
      prog =[0...4,2...5]
      score = Score::Tempo.new(120, start_meter: FOUR_FOUR, program: prog)
      converter = ScoreConverter.new(score,200)
      nscore = converter.convert_score
      expect(nscore.program).to eq(converter.convert_program)
    end

    it 'should use output from convert_parts' do
      changeA = Change::Immediate.new(Dynamics::PP)
      changeB = Change::Gradual.linear(Dynamics::F, 2)
      score = Score::Tempo.new(120, start_meter: FOUR_FOUR,
        parts: {"simple" => Part.new(Dynamics::MP, dynamic_changes: { 1 => changeA, 3 => changeB })}
      )
      converter = ScoreConverter.new(score,200)
      nscore = converter.convert_score
      expect(nscore.parts).to eq(converter.convert_parts)
    end
  end
end
