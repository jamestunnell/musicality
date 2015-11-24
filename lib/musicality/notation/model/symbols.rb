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
  Links::TIE => "~",
  Links::GLISSANDO => ";",
  Links::PORTAMENTO => ":",
}

SLUR_MARK_SYMBOLS = {
  SlurMarks::NONE => "",
  SlurMarks::BEGIN_SLUR => "(",
  SlurMarks::END_SLUR => ")",
}

end