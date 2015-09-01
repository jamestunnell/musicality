require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ScoreEngraver do
  describe '.part_titles' do
    context 'parts all have different instruments' do
      it 'should return a map of part names to instrument names' do
        parts = { 
          :part1 => Part.new(Dynamics::MP, instrument: Instruments::ELECTRIC_PIANO_1),
          :part2 => Part.new(Dynamics::MP, instrument: Instruments::VIOLIN),
          :part3 => Part.new(Dynamics::MP, instrument: Instruments::CONTRABASS)
        }
        titles = ScoreEngraver.figure_part_titles(parts)

        parts.each do |part_name, part|
          titles[part_name].should eq(part.instrument.name)
        end
      end
    end

    context 'some parts have same instrument' do
      it 'should return a map of part names to numbered instrument names' do
        parts = { 
          :part1 => Part.new(Dynamics::MP, instrument: Instruments::ELECTRIC_PIANO_1),
          :part2 => Part.new(Dynamics::MP, instrument: Instruments::ELECTRIC_PIANO_1),
          :part3 => Part.new(Dynamics::MP, instrument: Instruments::ELECTRIC_PIANO_1)
        }
        titles = ScoreEngraver.figure_part_titles(parts)

        part_nums = []
        parts.each do |part_name, part|
          r = Regexp.new("#{part.instrument.name} (\\d)")
          titles[part_name].should match r
          m = titles[part_name].match(r)
          part_nums.push m.captures.first.to_s.to_i
        end
        part_nums.sort.should eq((1..part_nums.size).to_a)
      end
    end
  end
end
