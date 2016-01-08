module Musicality

class PartEngraver
  MAX_LINE_LEN = 76
  INDENT = "  "

  def initialize part, title
    if part.invalid?
      raise ArgumentError, "given part contains errors: #{part.errors}"
    end

    @transpose_interval = part.lilypond_settings.transpose_interval
    @clefs = part.lilypond_settings.clefs
    @part = (@transpose_interval == 0) ? part : part.transpose(@transpose_interval)
    @title = title
    @indent = INDENT

    @triplet_flags = @part.notes.map do |note|
      note.duration.to_r.denominator % 3 == 0
    end
  end

  def increase_indent
    @indent += INDENT
  end

  def decrease_indent
    @indent = @indent[0...-INDENT.size]
  end

  def make_lilypond start_key, start_meter, key_changes: {}, meter_changes: {}, master: false
    if @transpose_interval != 0
      start_key = transpose_start_key(start_key)
      key_changes = transpose_key_changes(key_changes)      
    end

    sharpit = start_key.sharp?
    return make_preliminary(start_meter, start_key, master) + 
      make_body(sharpit) + make_final()
  end

  def make_preliminary start_meter, start_key, master
    clef = self.class.best_clef(@part.notes, @clefs)

    output = @indent + "\\new Staff {\n"
    increase_indent
    output += @indent + "\\set Staff.instrumentName = \\markup { \"#{@title}\" }\n"
    output += @indent + "\\clef #{clef}\n"
    if master
      output += @indent + start_meter.to_lilypond + "\n"
    end
    output += @indent + start_key.to_lilypond + "\n"
    return output
  end

  def make_body sharpit
    i = 0
    pieces = @part.notes.map do |n|
      str = if @triplet_flags[i]
        n.resize(n.duration * Rational(3,2)).to_lilypond(sharpit,
          begins_triplet: i == 0 || !@triplet_flags[i-1],
          ends_triplet: i == (@triplet_flags.size-1) || !@triplet_flags[i+1])
      else
        n.to_lilypond(sharpit)
      end
      i += 1
      str
    end

    output = ""
    while pieces.any?
      line = @indent + pieces.shift
      until pieces.empty? || (line.size + 1 + pieces.first.size) > MAX_LINE_LEN
        line += " " + pieces.shift
      end
      output += line + "\n"
    end
    return output
  end

  def make_final
    decrease_indent
    return @indent + "}\n"
  end 

  CLEF_RANGES = {
    Clef::TREBLE => Pitches::C4..Pitches::A5,
    Clef::ALTO => Pitches::D3..Pitches::B4,
    Clef::TENOR => Pitches::B2..Pitches::G4,
    Clef::BASS => Pitches::E2..Pitches::C4,
  }

  def self.best_clef notes, allowed_clefs
    raise ArgumentError unless notes.any?
    raise ArgumentError unless allowed_clefs.any?

    ranges = CLEF_RANGES.select {|clef,range| allowed_clefs.include?(clef) }
    range_scores = Hash.new(0)

    notes.each do |note|
      note.pitches.each do |p|
        ranges.each do |name,range|
          if p >= range.min && p <= range.max
            range_scores[name] += note.duration
          end
        end
      end
    end
    range_score = range_scores.max_by {|range,score| score}
    range_score.nil? ? allowed_clefs.first : range_score[0]
  end

  private

  def transpose_start_key start_key
    start_key.transpose(@transpose_interval)
  end

  def transpose_key_changes key_changes
    Hash[
      key_changes.map do |off,change|
        change.clone {|v| v.transpose(@transpose_interval) }
      end
    ]
  end
end

end