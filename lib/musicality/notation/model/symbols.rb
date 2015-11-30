module Musicality

# These symbols all need to match the notation parsers

ARTICULATION_SYMBOLS = {
  Articulations::TENUTO => "-",
  Articulations::ACCENT => ">",
  Articulations::MARCATO => "^",
  Articulations::PORTATO => "_",
  Articulations::STACCATO => ".",
  Articulations::STACCATISSIMO => "!",
}

LINK_SYMBOLS = {
  Link::Tie => "~",
  Link::Glissando => ";",
  Link::Portamento => ":",
}

MARK_SYMBOLS = {
  Mark::Slur::Begin => "(",
  Mark::Slur::End => ")",
  Mark::Triplet::Begin => "[",
  Mark::Triplet::End => "]",
}

end