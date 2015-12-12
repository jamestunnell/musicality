module Musicality

class PartEngraver
  MAX_LINE_LEN = 76
  INDENT = "  "

  def initialize part, title
    if part.invalid?
      raise ArgumentError, "given part contains errors: #{part.errors}"
    end

    settings = part.get_settings LilyPondSettings
    raise ArgumentError if settings.nil?
    @transpose_interval = settings.transpose_interval
    @clefs = settings.clefs
    @part = (@transpose_interval == 0) ? part : part.transpose(@transpose_interval)
    @title = title
    @indent = INDENT
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
    pieces = @part.notes.map {|n| n.to_lilypond(sharpit)}

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
    ranges = CLEF_RANGES.select {|clef,range| allowed_clefs.include?(clef) }
    range_scores = Hash.new(0)

    in_triplet = false
    notes.each do |note|
      if note.begins_triplet?
        in_triplet = true
      end

      dur = note.duration * (in_triplet ? Rational(2,3) : 1)
      note.pitches.each do |p|
        ranges.each do |name,range|
          if p >= range.min && p <= range.max
            range_scores[name] += dur
          end
        end
      end

      if note.ends_triplet?
        in_triplet = false
      end
    end
    range_score = range_scores.max_by {|range,score| score}
    return range_score[0]
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