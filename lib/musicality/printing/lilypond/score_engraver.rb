module Musicality

class ScoreEngraver
  LILYPOND_VERSION = "2.18.2"

  def initialize score
    @start_meter = score.start_meter
    @meter_changes = score.meter_changes
    @start_key = score.start_key
    @key_changes = score.key_changes
    @parts = score.collated? ? score.parts : ScoreCollator.new(score).collate_parts
    @header = ScoreEngraver.header score.title, score.composer
    @part_titles = ScoreEngraver.figure_part_titles @parts
  end

  def self.figure_part_titles parts    
    instr_name_totals = Hash.new(0)
    instr_name_used = Hash.new(0)
    part_titles = Hash[
      parts.map do |part_name, part|
        instr_name_totals[part.instrument.name] += 1
        [part_name, part.instrument.name]
      end
    ]

    needs_number = parts.keys.select {|part_name| instr_name_totals[part_titles[part_name]] > 1 }
    needs_number.each do |part_name|
      title = part_titles[part_name]
      part_titles[part_name] = "#{title} #{instr_name_used[title] += 1}"
    end

    return part_titles
  end

  # Generate a Lilypond header for the score
  def self.header title, composer
    output = "\\version \"#{LILYPOND_VERSION}\"\n"
    output += "\\header {\n"
    if title
      output += "  title = \"#{title}\"\n"
    end
    if composer
      output += "  composer = \"#{composer}\"\n"
    end
    output += "}\n"

    return output
  end

  def make_lilypond selected_parts = @parts.keys
    output = @header
    output += "{\n  <<\n"
    master = true
    selected_parts.each do |part_name|
      part = @parts[part_name]
      part_title = @part_titles[part_name]
      pe = PartEngraver.new(part, part_title)
      output += pe.make_lilypond(@start_key, @start_meter, 
        key_changes: @key_changes, meter_changes: @meter_changes,
        master: master)
      master = false if master
    end
    output += "  >>\n}\n"
    return output
  end
end

end