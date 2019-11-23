module Musicality
module Keys
  C_MAJOR = Key.major(PitchClasses::C)

  # Major keys with sharps
  G_MAJOR = Key.major(PitchClasses::G)
  D_MAJOR = Key.major(PitchClasses::D)
  A_MAJOR = Key.major(PitchClasses::A)
  E_MAJOR = Key.major(PitchClasses::E)
  B_MAJOR = Key.major(PitchClasses::B)

  # Major keys with flats
  F_MAJOR = Key.major(PitchClasses::F)
  Bb_MAJOR = Key.major(PitchClasses::Bb)
  Eb_MAJOR = Key.major(PitchClasses::Eb)
  Ab_MAJOR = Key.major(PitchClasses::Ab)
  Db_MAJOR = Key.major(PitchClasses::Db)
  Gb_MAJOR = Key.major(PitchClasses::Gb)

  A_MINOR = Key.minor(PitchClasses::A)

  # Minor keys with sharps
  E_MINOR = Key.minor(PitchClasses::E)
  B_MINOR = Key.minor(PitchClasses::B)
  Fs_MINOR = Key.minor(PitchClasses::Fs)
  Cs_MINOR = Key.minor(PitchClasses::Cs)
  Gs_MINOR = Key.minor(PitchClasses::Gs)

  # Minor keys with flats
  D_MINOR = Key.minor(PitchClasses::D)
  G_MINOR = Key.minor(PitchClasses::G)
  C_MINOR = Key.minor(PitchClasses::C)
  F_MINOR = Key.minor(PitchClasses::F)
  Bb_MINOR = Key.minor(PitchClasses::Bb)
  Eb_MINOR = Key.minor(PitchClasses::Eb)
end

end
