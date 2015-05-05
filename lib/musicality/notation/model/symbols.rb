module Musicality

ARTICULATION_SYMBOLS = {
  Articulations::SLUR => "(",
  Articulations::LEGATO => "[",
  Articulations::TENUTO => "_",
  Articulations::PORTATO => "%",
  Articulations::STACCATO => ".",
  Articulations::STACCATISSIMO => "'"
}

LINK_SYMBOLS = {
  Links::TIE => "=",
  Links::GLISSANDO => "~",
  Links::PORTAMENTO => "|",
  Links::SLUR => ARTICULATION_SYMBOLS[Articulations::SLUR],
  Links::LEGATO => ARTICULATION_SYMBOLS[Articulations::LEGATO],
}

ACCENT_SYMBOL = "!"

TRIPLET_CONNECTOR = ":"

end