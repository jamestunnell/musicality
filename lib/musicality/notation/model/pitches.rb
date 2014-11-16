module Musicality

module Pitches
  # Define pitch objects for octaves octave 0 through 9
  {
    :Bb => 10, :B => 11,
    :Cb => 11, :C => 0,
    :Db => 1, :D => 2,
    :Eb => 3, :E => 4,
    :Fb => 4, :F => 5,
    :Gb => 6, :G => 7,
    :Ab => 8, :A => 9,
  }.each do |sym,pc|
    (0..9).each do |octave|
      obj = Pitch.new octave: octave, semitone: pc
      Pitches.const_set(:"#{sym}#{octave}",obj)
    end
  end
end

end
