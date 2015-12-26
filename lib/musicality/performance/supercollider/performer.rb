module Musicality
module SuperCollider

class Performer
  RETRIGGER_HOLDOFF = 0.025
  VOLUME_CONTROL_SYNTHDEF = "volume_control"
  VOLUME_CHANGE_SYNTHDEF = "volume_change"
  MASTER_AUDIO_BUS = 0

  attr_reader :part
  def initialize part
    @synthdef_settings = part.synthdef_settings || DEFAULT_SYNTHDEF_SETTINGS
    @part = part
  end

  def bundles parent_group: nil, aux_audio_bus: 16, volume_control_bus: 0, lead_time: 0.1
    raise ArgumentError, "Lead time #{lead_time} is not positive" unless lead_time > 0.0
    bundles = []
    
    group = Group.tail(parent_group)
    bundles.push group.bundle_queue(0.0)

    # set start volume
    start_volume_msg = Message.new('/c_set', volume_control_bus, part.start_dynamic)
    bundles.push Bundle.new(0.0, start_volume_msg)

    # limit overall part output volume from local to master audio bus 
    vol_control = Synth.tail(group, VOLUME_CONTROL_SYNTHDEF,
      :in => aux_audio_bus,
      :out => MASTER_AUDIO_BUS,
      :control => volume_control_bus)
    bundles.push vol_control.bundle_queue(lead_time / 2.0)

    # change part volume
    part.dynamic_changes.each do |offset,change|
      case change
      when Change::Immediate
        change_volume_msg = Message.new('/c_set', volume_control_bus, change.end_value)
        bundles.push Bundle.new(offset+lead_time, change_volume_msg)
      when Change::Gradual
        raise ArgumentError, "absolute gradual changes are not supported yet" if change.absolute?

        vc = Synth.head(group, VOLUME_CHANGE_SYNTHDEF, 
          :vol_bus => volume_control_bus,
          :vol => change.end_value,
          :dur => change.duration)
        bundles.push vc.bundle_queue(offset+lead_time)

        vc.free
        bundles.push vc.bundle_queue(offset+lead_time+change.duration)
      else
        raise ArgumentError, "Unknown change type for #{change}"
      end
    end

    # play part notes
    note_sequences = NoteSequenceExtractor.new(part.notes).extract_sequences
    note_sequences.each do |note_seq|
      offsets = note_seq.offsets
      freqs = note_seq.elements.map {|el| el.pitch.freq }
      attacks = note_seq.elements.map {|el| el.attack }

      args = @synthdef_settings.args.merge(:freq => freqs[0], :gate => 1, :out => aux_audio_bus)
      s = Synth.head(group, @synthdef_settings.name, args)
      bundles.push s.bundle_queue(offsets[0]+lead_time)

      # change voice synth pitch
      offsets[1..-1].each_with_index do |offset,i|
        unless attacks[i] == Attack::NONE
          temp_offset = offset - RETRIGGER_HOLDOFF
          raise "Attacks are too close together" unless temp_offset > offsets[i-1]
          s.set(:gate => 0)
          bundles.push s.bundle_queue(temp_offset+lead_time)
        end
        
        set_args = { :freq => freqs[i] }
        unless attacks[i] == Attack::NONE
          set_args[:gate] = 1
        end
        s.set(set_args)
        bundles.push s.bundle_queue(offset+lead_time)
      end

      s.set(:gate => 0)
      bundles.push s.bundle_queue(note_seq.stop+lead_time)
    end

    bundles
  end
end

end
end