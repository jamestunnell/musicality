module Musicality

class ScoreEngraver
  LILYPOND_VERSION = "2.18.2"
  MAX_LINE_LEN = 76

  def initialize score
    case score
    when Score::Measured
      @start_meter = score.start_meter
    when Score::Unmeasured
      @start_meter = Meters::FOUR_FOUR
    else
      raise TypeError, "Only tempo-based score support Lilypond conversion"
    end

    @parts = score.collated? ? score.parts : ScoreCollator.new(score).collate_parts
    @title = score.title
    @composer = score.composer
  end

  # Generate a Lilypond header for the score
  def header
    output = "\\version \"#{LILYPOND_VERSION}\"\n"
    output += "\\header {\n"
    if @title
      output += "  title = \"#{@title}\"\n"
    end
    if @composer
      output += "  composer = \"#{@composer}\"\n"
    end
    output += "}\n"

    return output
  end

  # Generate a Lilypond staff for the given part
  def staff part, part_title, master: false
    clef = ScoreEngraver.best_clef(part.notes)
    output = "  \\new Staff {\n"
    output += "    \\set Staff.instrumentName = \\markup { \"#{part_title}\" }\n"
    output += "    \\clef #{clef}\n"
    if(master)
      output += "    \\time #{@start_meter.to_lilypond}\n"
    end

    line = "    "
    part.notes.each_index do |i|
      note = part.notes[i]
      begin
        str = note.to_lilypond + " "
      rescue UnsupportedDurationError => e
        binding.pry
      end

      if (line.size + str.size) > MAX_LINE_LEN
        output += line + "\n"
        line = "    "
      end
      line += str
    end
    output += line + "\n"

    output += "  }\n"
  end

  # @param [Hash] part_names A hash for titling parts differently than their names
  # @param [Array] selected_parts The names of parts selected for engraving
  def make_lilypond selected_parts: @parts.keys, part_titles: {}
    (selected_parts - part_titles.keys).each do |part_name|
      part_titles[part_name] = part_name
    end
    output = header
    output += "{\n  <<\n"
    master = true
    selected_parts.each do |part_name|
      part = @parts[part_name]
      part_title = part_titles[part_name]
      output += staff part, part_title, master: master
      master = false if master
    end
    output += "  >>\n}\n"
    return output
  end

  def self.best_clef notes
    ranges = { "treble" => Pitches::C4..Pitches::A5, 
                "bass" => Pitches::E2..Pitches::C4,
                "tenor" => Pitches::B2..Pitches::G4 }
    range_scores = { "treble" => 0, "bass" => 0, "tenor" => 0 }
    notes.each do |n|
      n.pitches.each do |p|
        ranges.each do |name,range|
          if p >= range.min && p <= range.max
            range_scores[name] += n.duration
          end
        end
      end
    end
    range_score = range_scores.max_by {|range,score| score}
    return range_score[0]
  end
end

end