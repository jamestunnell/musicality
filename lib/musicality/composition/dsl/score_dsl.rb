module Musicality

class ScoreDSL
  def self.load fname
    dsl = ScoreDSL.new
    dsl.instance_eval(File.read(fname), fname)
    dsl
  end

  attr_reader :score
  def initialize
    @score = nil
  end

  def tempo_score start_tempo, &block
    @score = Score::Tempo.new(start_tempo)
    @score.instance_eval(&block)
  end
end

end
