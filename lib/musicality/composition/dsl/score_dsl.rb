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

  def measured_score start_meter, start_tempo, &block
    @score = Score::Measured.new(start_meter,start_tempo)
    @score.instance_eval(&block)
  end
end

end