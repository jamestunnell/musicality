module Musicality

class Note
  SMALLEST_PIECE = Rational(1,256)

  def to_lilypond sharpit = false, begins_triplet: false, ends_triplet: false
    subdurs = [1]*@duration.to_i + fractional_subdurs(SMALLEST_PIECE)

    piece_strs = []
    pitches_to_strs = Hash[ pitches.map {|p| [p,p.to_lilypond(sharpit)] }]
    while subdurs.any?
      subdur = subdurs.shift
      dur_str = subdur.denominator.to_s
      if subdurs.any? && subdur == subdurs.first*2
        dur_str += "."
        subdurs.shift
      end
      last = subdurs.empty?

      piece_str = if pitches.any?
        if last
          # figure if ties are needed on per-pitch basis, based on note links
          if pitches_to_strs.size == 1
            p, p_str = pitches_to_strs.first
            needs_tie = links.include?(p) && links[p].is_a?(Link::Tie)
            p_str + dur_str + (needs_tie ? "~" : "")
          else
            p_strs = pitches_to_strs.map do |p,p_str|
              if links.include?(p) && links[p].is_a?(Link::Tie)
                p_str + "~"
              else
                p_str
              end
            end
            "<#{p_strs.join(" ")}>" + dur_str
          end
        else
          str = if pitches.size == 1
            pitches_to_strs.values.first
          else
            "<#{pitches_to_strs.values.join(" ")}>"
          end
          str + dur_str + "~"
        end
      else
        "r" + dur_str
      end

      piece_strs.push piece_str
    end

    if pitches.any?
      if articulation != Articulations::NORMAL
        piece_strs[0] += "-" + ARTICULATION_SYMBOLS[articulation]
      end

      if begins_slur?
        piece_strs[-1] += MARK_SYMBOLS[Mark::Slur::Begin]
      end

      if ends_slur?
        piece_strs[-1] += MARK_SYMBOLS[Mark::Slur::End]
      end
    end

    if begins_triplet
      piece_strs[0].prepend("\\tuplet 3/2 {")
    end

    if ends_triplet
      piece_strs[-1].concat("}")
    end

    return piece_strs.join(" ")
  end

  def fractional_subdurs smallest_piece
    remaining = @duration - @duration.to_i    
    pieces = []
    i = 0
    while((current_dur = Rational(1,2<<i)) >= smallest_piece)
      if remaining >= current_dur
        pieces.push current_dur
        remaining -= current_dur
      end
      i += 1
    end

    unless remaining.zero?
      raise RuntimeError, "Non-zero remainder #{remaining}"
    end

    return pieces
  end

  private


  def pieces_to_dur_strs pieces
    dur_strs = []
    while pieces.any?
      piece = pieces.shift
      triplet = piece.denominator % 3 == 0
      piece_str = (triplet ? (piece * 1.5.to_r) : piece).denominator.to_s
      if pieces.any? && piece == pieces.first*2
        piece_str += "."
        pieces.shift
      end

      if triplet
        piece_str = "\\tuplet 3/2 { #{piece_str} }"
      end

      dur_strs.push piece_str
    end
    return dur_strs
  end

  def figure_pitch_and_joipiece_str sharpit
    if pitches.any?
      if pitches.size == 1
        p_str = pitches.first.to_lilypond(sharpit)
      else
        p_str = "<" + pitches.map {|p| p.to_lilypond(sharpit) }.join(" ") + ">"
      end
      joipiece_str = "~ "
    else
      p_str = "r"
      joipiece_str = " "
    end
    return [ p_str, joipiece_str ]
  end
end

end