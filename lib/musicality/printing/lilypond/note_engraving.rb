module Musicality

class Note
  MAX_FRACT_PIECES = 7

  def to_lilypond sharpit = false
    d = duration
    dur_strs = ["1"]*d.to_i
   
    fract_pieces = duration_fractional_pieces(MAX_FRACT_PIECES)
    i = 0
    while i < fract_pieces.size
      piece = fract_pieces[i]
      piece_str = piece.denominator.to_s
      more_pieces = i < (fract_pieces.size - 1)
      if more_pieces && fract_pieces[i+1] == (piece/2)
        dur_strs.push piece_str + "."
        i += 2
      else
        dur_strs.push piece_str
        i += 1
      end
    end
    
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

    return dur_strs.map {|dur_str| p_str + dur_str }.join(join_str)
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
end

end