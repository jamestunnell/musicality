module Musicality

class NoteSequenceExtractor
  # For all link types:
  #  - Remove link where source pitch is not in current note
  # For tie:
  #  - Remove any bad tie (where the tying pitch does not exist in the next note).
  #  - Replace any good tie with a slur.
  # For slur/legato:
  #  - Remove any bad link (where the target pitch does not exist in the next note).
  # TODO: what to do about multiple links that target the same pitch?
  def self.fixup_links note, next_note
    note.links.each do |pitch, link|
      if !note.pitches.include?(pitch)
        note.links.delete pitch
      elsif link.is_a? Link::Tie
        if next_note.pitches.include? pitch
          note.links[pitch] = Link::Slur.new(pitch)
        else
          note.links.delete pitch
        end
      elsif (link.is_a?(Link::Slur) ||
             link.is_a?(Link::Legato))
        unless next_note.pitches.include? link.target_pitch
          note.links.delete pitch
        end
      end
    end
  end

  def self.replace_articulation note, next_note
    case note.articulation
    when Articulations::SLUR
      NoteLinker.fully_link(note, next_note, Link::Slur)
      note.articulation = Articulations::NORMAL
    when Articulations::LEGATO
      NoteLinker.fully_link(note, next_note, Link::Legato)
      note.articulation = Articulations::NORMAL
    end
  end

  attr_reader :notes
  def initialize notes, cents_per_step = 10
    @cents_per_step = cents_per_step
    @notes = notes.map do |n|
      n.is_a?(Triplet) ? n.expand : n.clone
    end.flatten

    @notes.push Note.quarter
    (@notes.size-1).times do |i|
      NoteSequenceExtractor.fixup_links(@notes[i], @notes[i+1])
      NoteSequenceExtractor.replace_articulation(@notes[i], @notes[i+1])
    end
    @notes.pop
  end

  def extract_sequences
    sequences = []
    offset = 0

    @notes.each_index do |i|
      while @notes[i].pitches.any?
        elements = []

        j = i
        loop do
          note = @notes[j]
          pitch = note.pitches.pop
          dur = note.duration
          accented = note.accented
          link = note.links[pitch]

          case link
          when Link::Slur
            elements.push(SlurredElement.new(dur, pitch, accented))
          when Link::Legato
            elements.push(LegatoElement.new(dur, pitch, accented))
          when Link::Glissando
            elements += GlissandoConverter.glissando_elements(pitch, link.target_pitch, dur, accented)
          when Link::Portamento
            elements += PortamentoConverter.portamento_elements(pitch, link.target_pitch, @cents_per_step, dur, accented)
          else
            elements.push(FinalElement.new(dur, pitch, accented, note.articulation))
            break
          end

          j += 1
          break if j >= @notes.size || !@notes[j].pitches.include?(link.target_pitch)
        end

        sequences.push(NoteSequence.from_elements(offset,elements))
      end
      offset += @notes[i].duration
    end

    return sequences
  end
end

end
