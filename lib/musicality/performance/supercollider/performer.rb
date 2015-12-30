module Musicality
module SuperCollider

class Performer
  MASTER_AUDIO_BUS = 0

  attr_reader :part, :settings
  def initialize part
    @settings = part.synthdef_settings || DEFAULT_SYNTHDEF_SETTINGS
    @part = part
    unless @settings.synthdef.params.has_key?(:out)
      raise ArgumentError "SynthDef #{@settings.synthdef} does not have :out param" 
    end
    @takes_freq = @settings.synthdef.params.has_key? :freq
    @takes_gate = @settings.synthdef.params.has_key? :gate
  end

  def bundles parent_group: nil, aux_audio_bus: 16, volume_control_bus: 0, lead_time: 0.1
    raise ArgumentError, "Lead time #{lead_time} is not positive" unless lead_time > 0.0
    bundles = []
    
    group = create_part_group parent_group, bundles
    set_start_volume volume_control_bus, bundles
    add_volume_control group, aux_audio_bus, volume_control_bus, lead_time, bundles
    add_volume_changes volume_control_bus, lead_time, bundles
    add_part_notes group, aux_audio_bus, lead_time, bundles

    bundles
  end

  private

  def create_part_group parent_group, bundles
    group = Group.tail(parent_group)
    bundles.push group.bundle_queue(0.0)
    return group
  end

  def set_start_volume volume_control_bus, bundles
    # set start volume
    start_volume_msg = Message.new('/c_set', volume_control_bus, part.start_dynamic)
    bundles.push Bundle.new(0.0, start_volume_msg)
  end

  def add_volume_control group, aux_audio_bus, volume_control_bus, lead_time, bundles
    # limit overall part output volume from local to master audio bus 
    vol_control = Synth.tail(group, SynthDefs::VOLUME_CONTROL.name,
      :in => aux_audio_bus,
      :out => MASTER_AUDIO_BUS,
      :control => volume_control_bus)
    bundles.push vol_control.bundle_queue(lead_time / 2.0)
  end

  def add_volume_changes volume_control_bus, lead_time, bundles
    # change part volume
    part.dynamic_changes.each do |offset,change|
      case change
      when Change::Immediate
        change_volume_msg = Message.new('/c_set', volume_control_bus, change.end_value)
        bundles.push Bundle.new(offset+lead_time, change_volume_msg)
      when Change::Gradual
        raise ArgumentError, "absolute gradual changes are not supported yet" if change.absolute?

        vc = Synth.head(group, SynthDefs::VOLUME_CHANGE.name, 
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
  end

  def add_part_notes group, aux_audio_bus, lead_time, bundles
    # play part notes
    NoteSequenceExtractor.new(part.notes).extract_sequences.each do |note_seq|
      offsets = note_seq.offsets
      freqs = note_seq.elements.map {|el| el.pitch.freq }
      attacks = note_seq.elements.map {|el| el.attack }

      args = setup_args(aux_audio_bus, freqs[0])
      s = Synth.head(group, @settings.synthdef.name, args)
      bundles.push s.bundle_queue(offsets[0]+lead_time)

      # change voice synth pitch
      (1...offsets.size).each do |i|
        offset = offsets[i]
        if attacks[i] == Attack::NONE
          s.set(:freq => freqs[i])
          bundles.push s.bundle_queue(offset+lead_time)
        else
          if @takes_gate
            s.set(:gate => 0)
            bundles.push s.bundle_queue(offset)
          end

          args = setup_args(aux_audio_bus, freqs[i])
          s = Synth.head(group, @settings.synthdef.name, args)
          bundles.push s.bundle_queue(offset+lead_time)
        end
      end

      if @takes_gate
        s.set(:gate => 0)
        bundles.push s.bundle_queue(note_seq.stop+lead_time)
      end
    end
  end

  def setup_args out, freq
    args = { :out => out }
    args[:freq] = freq if @takes_freq
    args[:gate] = 1 if @takes_gate
    @settings.args.merge(args)
  end
end

end
end