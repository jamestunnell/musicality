module Musicality

class NoteSequenceExtractor
  attr_reader :notes
  def initialize notes
    @notes = notes.map {|n| n.clone }
    mark_slurring
    remove_bad_links
    calculate_offsets

    # now, ready to extract sequences!
  end

  def extract_sequences cents_per_step = 10
    completed_seqs = []
    continuing_sequences = {}

    @notes.each_with_index do |note, idx|
      offset = @offsets[idx]
      duration = note.duration
      attack = NoteSequenceExtractor.note_attack(note.articulation)
      separation = NoteSequenceExtractor.note_separation(note.articulation, @slurring_flags[idx])

      next_note = (idx == (@notes.size-1)) ? Note.quarter : @notes[idx+1]
      continuation_map = NoteSequenceExtractor.continuation_map(note, next_note, separation)

      new_continuing_sequences = {}

      note.pitches.each do |p|
        seq = if continuing_sequences.has_key?(p)
          continuing_sequences[p].elements += note_pitch_elements(note, p, Attack::NONE, cents_per_step)
          continuing_sequences.delete(p)
        else
          NoteSequence.new(offset, separation, note_pitch_elements(note, p, attack, cents_per_step))
        end

        if continuation_map.include?(p)
          new_continuing_sequences[continuation_map[p]] = seq
        else
          completed_seqs.push seq
        end
      end

      if continuing_sequences.any?
        require 'pry'
        binding.pry
        # raise "Should be no previous continuing sequences remaining"
      end
      continuing_sequences = new_continuing_sequences
    end

    raise "Should be no previous continuing sequences remaining" if continuing_sequences.any?

    completed_seqs.each {|seq| seq.simplify! }
    return completed_seqs
  end

  private

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

  def self.continuation_map note, next_note, separation
    map = {}

    linked = note.pitches & note.links.keys
    targeted = []
    linked.each do |p|
      l = note.links[p]
      if l.is_a?(Link::Tie)
        map[p] = p
      elsif l.is_a?(Link::TargetedLink) && next_note.pitches.include?(l.target_pitch)
        map[p] = l.target_pitch
      end
    end

    if(separation == Separation::NONE)
      unlinked = note.pitches - linked
      untargeted = next_note.pitches - map.values
      Optimization.linking(unlinked, untargeted).each do |pitch,tgt_pitch|
        map[pitch] = tgt_pitch
      end
    end

    return map
  end

  def note_pitch_elements note, pitch, attack, cents_per_step
    duration = note.duration
    link = note.links[pitch]
    elements = if link && link.is_a?(Link::TargetedLink)
      tgt_pitch = link.target_pitch
      case link
      when Link::Glissando
        GlissandoConverter.glissando_elements(pitch, tgt_pitch, duration, attack)
      when Link::Portamento
        PortamentoConverter.portamento_elements(pitch, tgt_pitch, cents_per_step, duration, attack)
      else
        raise "Unexpected targeted link type"
      end
    else
      [ NoteSequence::Element.new(note.duration, pitch, attack) ]
    end

    return elements
  end
end

end
