module Musicality

class PartSequencer
  def initialize part, dynamics_sample_rate: 50, cents_per_step: 10
    notes = part.notes.map {|n| n.clone }
    replace_portamento_with_glissando(notes)
    
    extractor = NoteSequenceExtractor.new(notes)
    note_sequences = extractor.extract_sequences(cents_per_step)
    note_events = gather_note_events(note_sequences)
    
    dynamic_events = gather_dynamic_events(part.start_dynamic,
      part.dynamic_changes, dynamics_sample_rate)
    
    @events = (note_events + dynamic_events).sort
  end
  
  def make_midi_track midi_sequence, part_name, channel, ppqn, program
    track = begin_track(midi_sequence, part_name, channel, program)
    
    prev_offset = 0
    @events.each do |offset, event|
      if offset == prev_offset
        delta = 0
      else
        delta = MidiUtil.delta(offset - prev_offset, ppqn)
      end
      
      track.events << case event
      when MidiEvent::NoteOn
        vel = MidiUtil.note_velocity(event.attack)
        MIDI::NoteOn.new(channel, event.notenum, vel, delta)
      when MidiEvent::NoteOff
        MIDI::NoteOff.new(channel, event.notenum, 127, delta)
      when MidiEvent::Expression
        MIDI::Controller.new(channel, MIDI::CC_EXPRESSION_CONTROLLER, event.volume, delta)
      end
      
      prev_offset = offset
    end
   return track
  end
  
  private
  
  def replace_portamento_with_glissando notes
    notes.each do |note|
      note.links.each do |pitch,link|
        if link.is_a? Link::Portamento
          note.links[pitch] = Link::Glissando.new(link.target_pitch)
        end
      end
    end
  end
  
  def gather_note_events note_sequences
    note_events = []
    note_sequences.each do |note_seq|
      offsets, elements = note_seq.offsets, note_seq.elements

      elements.each_index do |i|
        offset, element = offsets[i], elements[i]
        pitch, attack = element.pitch, element.attack
        
        note_num = MidiUtil.pitch_to_notenum(pitch)
        on_at = offset
        off_at = (i < (offsets.size - 1)) ? offsets[i+1] : note_seq.stop
        
        note_events.push [on_at, MidiEvent::NoteOn.new(note_num, attack)]
        note_events.push [off_at, MidiEvent::NoteOff.new(note_num)]
      end
    end
    return note_events
  end
  
  def gather_dynamic_events start_dyn, dyn_changes, sample_rate
    dynamic_events = []
    
    dyn_comp = ValueComputer.new(start_dyn,dyn_changes)
    finish = 0
    if dyn_changes.any?
      finish = dyn_changes.map {|off,ch| ch.offsets(off).max }.max
    end
    samples = dyn_comp.sample(0..finish, sample_rate)
    
    prev = nil
    samples.each_index do |i|
      sample = samples[i]
      unless sample == prev
        offset = Rational(i,sample_rate)
        volume = MidiUtil.dynamic_to_volume(sample)
        dynamic_events.push [offset, MidiEvent::Expression.new(volume)]
      end
      prev = sample
    end
    
    return dynamic_events
  end

  def begin_track midi_sequence, track_name, channel, program
    raise ArgumentError, "Program number #{program} is not in range 1-128" unless program.between?(1,128)
    program_idx = program - 1 # program numbers start at 1, array indices start at 0

    # Track to hold part notes
    track = MIDI::Track.new(midi_sequence)
    
    # Name the track and instrument
    track.name = track_name
    track.instrument = MIDI::GM_PATCH_NAMES[program_idx]
    
    # Add a volume controller event (optional).
    track.events << MIDI::Controller.new(channel, MIDI::CC_VOLUME, 127)
    
    # Change to particular instrument sound
    track.events << MIDI::ProgramChange.new(channel, program_idx)
    
    return track
  end
end

end