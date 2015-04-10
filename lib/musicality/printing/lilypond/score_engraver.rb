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
  end

  def make_lilypond part_names = nil
    part_names ||= @parts.keys
    output = "\\version \"#{LILYPOND_VERSION}\"\n{\n  <<\n"
    master = true
    part_names.each do |part_name|
      part = @parts[part_name]
      
      clef = ScoreEngraver.best_clef(part.notes)
      output += "  \\new Staff {\n"
      output += "    \\clef #{clef}\n"
      if(master)
        output += "    \\time #{@start_meter.to_lilypond}\n"
      end

      line = ""
      part.notes.each_index do |i|
        note = part.notes[i]
        begin
          str = note.to_lilypond
        rescue UnsupportedDurationError => e
          binding.pry
        end

        if (line.size + str.size) > MAX_LINE_LEN
          output += "    " + line
          line = ""
        end
        line += str
      end
      output += "    " + line

      output += "  }\n"
      
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