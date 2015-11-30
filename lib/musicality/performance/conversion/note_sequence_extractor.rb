module Musicality

class NoteSequenceExtractor
  attr_reader :notes
  def initialize notes
    prepare_notes(notes)
    mark_slurring
    remove_bad_links
    calculate_offsets
    establish_maps
    # now, ready to extract sequences!
  end
  
  def extract_sequences cents_per_step = 10
    return [] if @notes.empty?
    
    next_seqs = seqs_from_note(@notes.size-1, cents_per_step)
    return next_seqs if @notes.one?
    
    complete_seqs = []
    (@notes.size-2).downto(0) do |i|
      cur_seqs = seqs_from_note(i, cents_per_step)
      map = @maps[i]
      
      next_seqs.each do |next_seq|
        p1 = nil
        p2 = next_seq.elements.first.pitch
        if p1 = map[:ties].key(p2)
          cur_seq = cur_seqs.find {|x| x.elements.first.pitch == p1 }
          NoteSequenceExtractor.tie_seqs(cur_seq, next_seq)
        elsif p1 = map[:slurs].key(p2)
          cur_seq = cur_seqs.find {|x| x.elements.first.pitch == p1 }
          NoteSequenceExtractor.slur_seqs(cur_seq, next_seq)
        elsif p1 = map[:full_glissandos].key(p2)
          cur_seq = cur_seqs.find {|x| x.elements.first.pitch == p1 }
          NoteSequenceExtractor.glissando_seqs(cur_seq, next_seq)
        elsif p1 = map[:full_portamentos].key(p2)
          cur_seq = cur_seqs.find {|x| x.elements.first.pitch == p1 }
          NoteSequenceExtractor.portamento_seqs(cur_seq, next_seq, cents_per_step)
        else
          complete_seqs.push next_seq
        end
      end      
      next_seqs = cur_seqs
    end
    complete_seqs += next_seqs
    return complete_seqs
  end
  
  private
  
  def self.tie_seqs(cur_seq, next_seq)
    cur_seq.elements.last.duration += next_seq.elements.first.duration
    cur_seq.elements += next_seq.elements[1..-1]
  end
  
  def self.slur_seqs(cur_seq, next_seq)
    if next_seq.elements.first.attack == Attack::NORMAL
      next_seq.elements.first.attack = Attack::NONE
    end
    cur_seq.separation = next_seq.separation
    cur_seq.elements += next_seq.elements
  end

  def self.glissando_seqs(cur_seq, next_seq)
    cur_seq.elements = GlissandoConverter.glissando_elements(cur_seq.last_pitch,
      next_seq.first_pitch, cur_seq.full_duration, cur_seq.last_attack)
    cur_seq.separation = next_seq.separation
    cur_seq.elements += next_seq.elements
  end

  def self.portamento_seqs(cur_seq, next_seq, cents_per_step)
    cur_seq.elements = PortamentoConverter.portamento_elements(cur_seq.last_pitch,
      next_seq.first_pitch, cents_per_step, cur_seq.full_duration, cur_seq.last_attack)
    cur_seq.separation = Separation::NONE
    cur_seq.elements += next_seq.elements    
  end
  
  def seqs_from_note(idx, cents_per_step)
    map = @maps[idx]
    note = @notes[idx]
    attack = NoteSequenceExtractor.note_attack(note.articulation)
    separation = NoteSequenceExtractor.note_separation(note.articulation, @slurring_flags[idx])
    offset = @offsets[idx]
    note.pitches.map do |p|
      if map[:half_glissandos].has_key?(p)
        NoteSequence.new(offset, separation, 
          GlissandoConverter.glissando_elements(
            p, map[:half_glissandos][p], note.duration, attack))
      elsif map[:half_portamentos].has_key?(p)
        NoteSequence.new(offset, Separation::NONE, 
          PortamentoConverter.portamento_elements(
            p, map[:half_portamentos][p], cents_per_step, note.duration, attack))
      else
        NoteSequence.new(offset, separation,
          [NoteSequence::Element.new(note.duration, p, attack)])
      end
    end
  end

  def self.note_attack articulation
    case articulation
    when Articulations::NORMAL then Attack::NORMAL
    when Articulations::TENUTO then Attack::TENUTO
    when Articulations::ACCENT then Attack::ACCENT
    when Articulations::MARCATO then Attack::ACCENT
    when Articulations::PORTATO then Attack::NORMAL
    when Articulations::STACCATO then Attack::NORMAL
    when Articulations::STACCATISSIMO then Attack::NORMAL
    end
  end

  def self.note_separation articulation, under_slur
    if under_slur
      case articulation
      when Articulations::NORMAL then Separation::NONE
      when Articulations::TENUTO then Separation::NONE
      when Articulations::ACCENT then Separation::NONE
      when Articulations::MARCATO then Separation::PORTATO
      when Articulations::PORTATO then Separation::NORMAL
      when Articulations::STACCATO then Separation::PORTATO
      when Articulations::STACCATISSIMO then Separation::STACCATO
      end
    else
      case articulation
      when Articulations::NORMAL then Separation::NORMAL
      when Articulations::TENUTO then Separation::TENUTO
      when Articulations::ACCENT then Separation::NORMAL
      when Articulations::MARCATO then Separation::NORMAL
      when Articulations::PORTATO then Separation::PORTATO
      when Articulations::STACCATO then Separation::STACCATO
      when Articulations::STACCATISSIMO then Separation::STACCATISSIMO
      end
    end
  end

  def prepare_notes notes
    in_triplet = false
    @notes = Array.new(notes.size) do |i|
      note = notes[i]

      if note.begins_triplet?
        in_triplet = true
      end
      
      new_note = in_triplet ? note.resize(note.duration * Rational(2,3)) : note.clone

      if note.ends_triplet?
        in_triplet = false
      end

      new_note
    end
  end

  def mark_slurring
    @slurring_flags = []
    under_slur = false
    
    @slurring_flags = Array.new(@notes.size) do |i|
      note = @notes[i]

      if note.begins_slur? && !note.ends_slur?
        under_slur = true
      end
      flag = under_slur

      if note.ends_slur? && !note.begins_slur?
        under_slur = false
      end
      flag
    end
  end

  def remove_bad_links
    @notes.each_with_index do |n,i|
      # create a dummy note (with no pitches) for checking links from the last note
      n2 = (i == (@notes.size-1)) ? Note.quarter : @notes[i+1]
      n.links.delete_if do |p,l|
        !n.pitches.include?(p) || (l.is_a?(Link::Tie) && !n2.pitches.include?(p))
      end
    end
  end
    
  def calculate_offsets
    offset = 0.to_r
    @offsets = Array.new(@notes.size) do |i|
      cur_offset = offset
      offset += @notes[i].duration
      cur_offset
    end
  end
  
  def self.no_separation?(articulation, under_slur)
    under_slur && (
      articulation == Articulations::NORMAL ||
      articulation == Articulations::TENUTO ||
      articulation == Articulations::ACCENT
    )
  end
  
  def establish_maps
    @maps = []
    
    @notes.each_index do |i|
      map = { :ties => {}, :slurs => {}, :full_glissandos => {}, 
        :full_portamentos => {}, :half_glissandos => {}, 
        :half_portamentos => {}}
      note = @notes[i]
      
      # Create a dummy note (with no pitches) for the last note to "link" to.
      # This will allow half glissandos and half portamentos from the last note
      next_note = (i == (@notes.size-1)) ? Note.quarter : @notes[i+1]
      
      no_separation = NoteSequenceExtractor.no_separation?(note.articulation, @slurring_flags[i])
      
      linked = note.pitches & note.links.keys
      linked.each do |p|
        l = note.links[p]
        if l.is_a?(Link::Tie)
          map[:ties][p] = p
        elsif l.is_a?(Link::Glissando)
          if next_note.pitches.include?(l.target_pitch)
            map[:full_glissandos][p] = l.target_pitch
          else
            map[:half_glissandos][p] = l.target_pitch
          end
        elsif l.is_a?(Link::Portamento)
          if next_note.pitches.include?(l.target_pitch)
            map[:full_portamentos][p] = l.target_pitch
          else
            map[:half_portamentos][p] = l.target_pitch
          end
        end
      end
      
      if(no_separation)
        unlinked = note.pitches - linked
        target_pitches = note.links.map {|p,l| l.is_a?(Link::Tie) ? p : l.target_pitch }
        untargeted = next_note.pitches - target_pitches
        Optimization.linking(unlinked, untargeted).each do |pitch,tgt_pitch|
          map[:slurs][pitch] = tgt_pitch
        end
      end
      
      @maps.push map
    end
  end
end

end
