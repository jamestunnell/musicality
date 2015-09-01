module Musicality

class PartEngraver
  MAX_LINE_LEN = 76

  def initialize part, title
    @transpose_interval = part.instrument.transpose_interval
    @part = (@transpose_interval == 0) ? part : part.transpose(@transpose_interval)
    @title = title
  end

  def make_lilypond start_key, start_meter, key_changes: {}, meter_changes: {}, master: false
    if @transpose_interval != 0
      start_key = start_key.transpose(@transpose_interval)
      key_changes = Hash[
        key_changes.map do |off,change|
          change.clone {|v| v.transpose(@transpose_interval) }
        end
      ]
    end

    clef = self.class.best_clef(@part.notes, @part.instrument.clefs)
    sharpit = start_key.sharp?

    output = "  \\new Staff {\n"
    output += "    \\set Staff.instrumentName = \\markup { \"#{@title}\" }\n"
    output += "    \\clef #{clef}\n"
    if(master)
      output += "    #{start_meter.to_lilypond}\n"
    end
    output += "    #{start_key.to_lilypond}"

    line = "    "
    @part.notes.each do |note|
      begin
        str = note.to_lilypond(sharpit) + " "
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

  CLEF_RANGES = {
    Instrument::TREBLE => Pitches::C4..Pitches::A5,
    Instrument::ALTO => Pitches::D3..Pitches::B4,
    Instrument::TENOR => Pitches::B2..Pitches::G4,
    Instrument::BASS => Pitches::E2..Pitches::C4,
  }

  def self.best_clef notes, allowed_clefs
    ranges = CLEF_RANGES.select {|clef,range| allowed_clefs.include?(clef) }
    range_scores = Hash.new(0)
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