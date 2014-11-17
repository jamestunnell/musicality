module Musicality

class GlissandoConverter
  def self.glissando_pitches(start_pitch, target_pitch)
    start, finish = start_pitch.total_semitones, target_pitch.total_semitones
    if finish >= start
      semitones = start.ceil.upto(finish.floor).to_a
    else
      semitones = start.floor.downto(finish.ceil).to_a
    end
    
    if semitones.empty? || semitones[0] != start
      semitones.unshift(start)
    end
    
    if semitones.size > 1 && semitones[-1] == finish
      semitones.pop
    end
    
    semitones.map do |semitone|
      Pitch.from_semitones(semitone)
    end
  end

  def self.glissando_elements(start_pitch, target_pitch, duration, accented)
    pitches = glissando_pitches(start_pitch, target_pitch)
    subdur = Rational(duration, pitches.size)
    pitches.map do |pitch|
      LegatoElement.new(subdur, pitch, accented)
    end
  end
end

end
