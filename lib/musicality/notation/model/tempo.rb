module Musicality

class Tempo
  attr_reader :value
  def initialize value
    raise NonPositiveError, "Given tempo value #{value} is not positive" if value <= 0
    @value = value
  end
  
  def ==(other)
    self.class == other.class && self.value == other.value
  end
  
  def clone
    self.class.new(@value)
  end
  
  class QNPM < Tempo; def to_s; "#{@value}qnpm" end; end
  class NPM < Tempo; def to_s; "#{@value}npm" end; end
  class BPM < Tempo; def to_s; "#{@value}bpm" end; end
  class NPS < Tempo; def to_s; "#{@value}nps" end; end
end

end