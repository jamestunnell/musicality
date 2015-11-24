module Musicality

class PortamentoConverter
  def self.portamento_pitches(start_pitch, target_pitch, cents_per_step)
    start, finish = start_pitch.total_cents, target_pitch.total_cents
    step_size = finish >= start ? cents_per_step : -cents_per_step
    nsteps = ((finish - 1 - start) / step_size.to_f).ceil
    cents = Array.new(nsteps+1){|i| start + i * step_size }
    
    cents.map do |cent|
      Pitch.new(cent: cent)
    end
  end

  def self.portamento_elements(start_pitch, target_pitch, cents_per_step, duration, attack)
    pitches = portamento_pitches(start_pitch, target_pitch, cents_per_step)
    subdur = Rational(duration, pitches.size)
    first = true
    pitches.map do |pitch|
      el = NoteSequence::Element.new(subdur, pitch, first ? attack : Attack::NONE)
      first = false
      el
    end
  end
end

end
