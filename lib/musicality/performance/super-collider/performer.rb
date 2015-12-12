module Musicality
module SuperCollider

class Performer
  def initialize part, group, cents_per_step
    nse = NoteSequenceExtractor.new(part.notes)
    @note_sequences = nse.extract_sequences(cents_per_step)

    settings = part.settings[:SuperCollider]
    @synthdef = settings ? settings.synthdef : "default"
    @start_values = settings ? settings.start_values : {}
  end
end

end
end