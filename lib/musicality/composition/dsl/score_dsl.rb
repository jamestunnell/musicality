module Musicality

class ScoreDSL
  def self.load fname
    include Musicality
    include Pitches
    include Articulations
    include Meters
    include Dynamics

    dsl = ScoreDSL.new
    dsl.instance_eval(File.read(fname), fname)
    dsl
  end

  def initialize
    @score = nil
  end

  def score start_meter, start_tempo, &block
    @score = Score::Measured.new(start_meter,start_tempo)
    @score.instance_eval(&block)
  end

  def score_yaml
    @score.pack.to_yaml
  end
end

end