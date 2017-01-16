module Musicality

module PitchClasses
  C = Bs = 0
  Cs = Db = 1
  D = 2
  Ds = Eb = 3
  E = Fb = 4
  Es = F = 5
  Fs = Gb = 6
  G = 7
  Gs = Ab = 8
  A = 9
  As = Bb = 10
  B = Cb = 11
end

PITCH_CLASSES = PitchClasses.constants.map { |sym| PitchClasses.const_get(sym) }.sort

end
