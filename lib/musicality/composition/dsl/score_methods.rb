module Musicality

class Score
  def section title, &block
    a = duration
    self.instance_eval(&block)
    b = duration
    @sections[title] = a...b
  end

  def repeat arg
    case arg
    when Range
      program.push arg
    when String,Symbol
      program.push @sections.fetch(arg)
    else
      raise ArgumentError, "Arg is not a Range, String, or Symbol"
    end
  end

  DEFAULT_START_DYNAMIC = Dynamics::MF
  def notes part_notes
    raise ArgumentError, "No part notes given" if part_notes.empty?

    durs_uniq = part_notes.values.map do |notes|
      notes.map {|n| n.duration }.inject(0,:+)
    end.uniq
    raise DurationMismatchError, "New part note durations do not all match" if durs_uniq.size > 1
    dur = durs_uniq.first

    a = starting_part_dur = self.duration
    part_notes.each do |part,notes|
      unless parts.has_key? part
        parts[part] = Part.new DEFAULT_START_DYNAMIC
        if starting_part_dur > 0
          parts[part].notes.push Note.new(starting_part_dur)
        end
      end
      parts[part].notes += notes
    end
    (parts.keys - part_notes.keys).each do |part|
      parts[part].notes.push Note.new(dur)
    end

    b = self.duration
    program.push a...b
    a...b
  end

  def dynamic_change new_dynamic, transition_dur: 0, offset: 0
    if transition_dur == 0
      change = (transition_dur == 0) ? Change::Immediate.new(new_tempo) : Change::Gradual.linear(new_tempo, transition_dur)
      parts.values.each do |part|
        part.tempo_changes[self.duration + offset] = change
      end
    end
  end
  
  class Tempo < Score
    def tempo_change new_tempo, transition_dur: 0, offset: 0
      if transition_dur == 0
        tempo_changes[self.duration + offset] = Change::Immediate.new(new_tempo)
      else
        tempo_changes[self.duration + offset] = Change::Gradual.linear(new_tempo, transition_dur)
      end
    end
    
    def meter_change new_meter, offset: 0
      meter_changes[self.duration + offset] = Change::Immediate.new(new_meter)
    end

    def key_change new_key, offset: 0
      key_changes[self.duration + offset] = Change::Immediate.new(new_key)
    end
  end
end

end
