require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ScoreEngraver do
  describe '.part_titles' do
    context 'parts all have different lilypond settings' do
      it 'should return a map of part names to instrument names' do
        parts = {
          :part1 => Part.new(Dynamics::MP, settings: [ LilypondSettings::ELECTRIC_PIANO ]),
          :part2 => Part.new(Dynamics::MP, settings: [ LilypondSettings::ELECTRIC_BASS ]),
          :part3 => Part.new(Dynamics::MP, settings: [ LilypondSettings::CLARINET ])
        }
        titles = ScoreEngraver.figure_part_titles(parts)

        parts.each do |part_name, part|
          expect(titles[part_name]).to eq(part.lilypond_settings.instrument_name)
        end
      end
    end

    context 'some parts have same lilypond settings' do
      it 'should return a map of part names to numbered instrument names' do
        parts = {
          :part1 => Part.new(Dynamics::MP, settings: [ LilypondSettings::ELECTRIC_PIANO ]),
          :part2 => Part.new(Dynamics::MP, settings: [ LilypondSettings::ELECTRIC_PIANO ]),
          :part3 => Part.new(Dynamics::MP, settings: [ LilypondSettings::ELECTRIC_PIANO ])
        }
        titles = ScoreEngraver.figure_part_titles(parts)

        part_nums = []
        parts.each do |part_name, part|
          r = Regexp.new("#{part.lilypond_settings.instrument_name} (\\d)")
          expect(titles[part_name]).to match r
          m = titles[part_name].match(r)
          part_nums.push m.captures.first.to_s.to_i
        end
        expect(part_nums.sort).to eq((1..part_nums.size).to_a)
      end
    end
  end
end
