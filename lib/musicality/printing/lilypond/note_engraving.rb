module Musicality

class Note
  MAX_FRACT_PIECES = 7

  def to_lilypond sharpit = false
    whole_count = @duration.to_i
    fractional_pieces = duration_fractional_pieces(MAX_FRACT_PIECES)
    
    plain_dur_strs = ["1"]*whole_count
    plain_dur_strs += pieces_to_dur_strs(fractional_pieces)
    p_str, join_str = figure_pitch_and_join_str

    plain_output = plain_dur_strs.map {|dur_str| p_str + dur_str }.join(join_str)
    return plain_output
  end

  private

  def duration_fractional_pieces max_n_pieces
    remaining = @duration - @duration.to_i
    pieces = []
    max_n_pieces.times do |i|
      break if remaining == 0
      current_piece = Rational(1, 2 << i)
      if remaining >= current_piece
        pieces.push current_piece
        remaining -= current_piece
      end
    end
    unless remaining.zero?
      raise UnsupportedDurationError, "Duration #{@duration} could not be broken down \
        into #{max_n_pieces} fractional pieces. #{remaining} was remaining."
    end
    return pieces
  end

  def pieces_to_dur_strs pieces
    dur_strs = []
    while pieces.any?
      piece = pieces.shift
      piece_str = piece.denominator.to_s
      if pieces.any? && piece == pieces.first*2
        piece_str += "."
        pieces.shift
      end
      dur_strs.push piece_str
    end
    return dur_strs
  end

  def figure_pitch_and_join_str
    if pitches.any?
      if pitches.size == 1
        p_str = pitches.first.to_lilypond
      else
        p_str = "<" + pitches.map {|p| p.to_lilypond}.join(" ") + ">"
      end
      join_str = "~ "
    else
      p_str = "r"
      join_str = " "
    end
    return [ p_str, join_str ]
  end
end

end