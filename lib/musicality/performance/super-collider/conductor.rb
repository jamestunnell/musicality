module Musicality
module SuperCollider

class Conductor
  def initialize score, server, cents_per_step
    unless score.is_a?(Score::Timed)
      raise ArgumentError, "The given score is not a Score::Timed. \
      Convert it first using ScoreConverter."
    end
    raise ArgumentError unless (server.is_a?(Collider::Server) && server.running?)

    parts = score.collated? ? score.parts : ScoreCollator.new(score).collate_parts
    @performers = Hash[ parts.map do |name, part|
      [name, Performer.new(part, Collider::Group.tail(server.default_group), cents_per_step)]
    end]
  end

  def perform selected_parts = @performers.keys
    
  end
end

end
end