module Musicality

module PitchClasses  
  C = 0
  Db = 1
  D = 2
  Eb = 3
  E = 4
  F = 5
  Gb = 6
  G = 7
  Ab = 8
  A = 9
  Bb = 10
  B = 11
end

PITCH_CLASSES = PitchClasses.constants.map do |sym|
  PitchClasses.const_get(sym)
end.sort

end