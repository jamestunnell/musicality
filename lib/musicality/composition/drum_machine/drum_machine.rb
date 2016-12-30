module Musicality

class DrumMachine
  def initialize drum_patterns
    @drum_patterns = drum_patterns
    @num_patterns = @drum_patterns.size
    @pattern_idx = 0

    raise ArgumentError if (@num_patterns == 0)
  end

  def next
    pattern = @drum_patterns[@pattern_idx]
    @pattern_idx += 1

    if @pattern_idx >= @num_patterns
      @pattern_idx = 0
    end

    return pattern.part_notes
  end

  def reset
    @pattern_idx = 0
  end
end

end
