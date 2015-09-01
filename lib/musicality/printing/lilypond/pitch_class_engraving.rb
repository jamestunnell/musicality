module Musicality

class PitchClass
  def self.to_lilypond pc, sharpit = false
    case pc
    when 0 then "c"
    when 1 then sharpit  ? "cis" : "des"
    when 2 then "d"
    when 3 then sharpit  ? "dis" : "ees"
    when 4 then "e"
    when 5 then "f"
    when 6 then sharpit  ? "fis" : "ges"
    when 7 then "g"
    when 8 then sharpit  ? "gis" : "aes"
    when 9 then "a"
    when 10 then sharpit  ? "ais" : "bes"
    when 11 then "b"
    end
  end
end

end
