module Musicality

class ScoreSequencer
  def initialize score
    unless score.is_a?(Score::Timed)
      raise ArgumentError, "The given score is not a Score::Timed. \
      Convert it first using ScoreConverter."
    end
    
    @parts = score.collated? ? score.parts : ScoreCollator.new(score).collate_parts

    # parts should all have MIDI settings, defaults if necessary
    @parts.each do |part_name, part|
      unless part.has_settings? MidiSettings
        part.settings.push MidiSettings.new(1)
      end
    end

    # part names should all be strings, because 1) a midi track name needs to
    # be a string and 2) the instrument map used to map part names to MIDI
    # program numbers will use part name strings as keys.
    @parts = Hash[ @parts.map {|k,v| [k.to_s,v] } ]
  end
  
  USEC_PER_QUARTER_SEC = 250000
  
  def make_midi_seq selected_parts = @parts.keys
    seq = MIDI::Sequence.new()
    
    # first track for the sequence holds time sig and tempo events
    track0 = MIDI::Track.new(seq)
    seq.tracks << track0
    track0.events << MIDI::Tempo.new(USEC_PER_QUARTER_SEC)
    track0.events << MIDI::MetaEvent.new(MIDI::META_SEQ_NAME, 'Sequence Name')
    
    channel = 0
    selected_parts.each do |part_name|
      part = @parts[part_name]
      program = part.get_settings(MidiSettings).program      
      pseq = PartSequencer.new(part)
      seq.tracks << pseq.make_midi_track(seq, part_name, channel, seq.ppqn, program)
      channel += 1
    end
    
    return seq
  end
end

end
