# Autogenerated from a Treetop grammar. Edits may be lost.


module Musicality
module Parsing

module Note
  include Treetop::Runtime

  def root
    @root ||= :note
  end

  include Pitch

  include Articulation

  include Link

  include Duration

  def _nt_note
    start_index = index
    if node_cache[:note].has_key?(index)
      cached = node_cache[:note][index]
      if cached
        node_cache[:note][index] = cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    i0 = index
    r1 = _nt_triplet
    if r1
      r1 = SyntaxNode.new(input, (index-1)...index) if r1 == true
      r0 = r1
    else
      r2 = _nt_single_note
      if r2
        r2 = SyntaxNode.new(input, (index-1)...index) if r2 == true
        r0 = r2
      else
        @index = i0
        r0 = nil
      end
    end

    node_cache[:note][start_index] = r0

    r0
  end

  module Triplet0
    def first
      elements[0]
    end

    def second
      elements[2]
    end

    def third
      elements[4]
    end
  end

  def _nt_triplet
    start_index = index
    if node_cache[:triplet].has_key?(index)
      cached = node_cache[:triplet][index]
      if cached
        node_cache[:triplet][index] = cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    i0, s0 = index, []
    r1 = _nt_single_note
    s0 << r1
    if r1
      if (match_len = has_terminal?(":", false, index))
        r2 = true
        @index += match_len
      else
        terminal_parse_failure('":"')
        r2 = nil
      end
      s0 << r2
      if r2
        r3 = _nt_single_note
        s0 << r3
        if r3
          if (match_len = has_terminal?(":", false, index))
            r4 = true
            @index += match_len
          else
            terminal_parse_failure('":"')
            r4 = nil
          end
          s0 << r4
          if r4
            r5 = _nt_single_note
            s0 << r5
          end
        end
      end
    end
    if s0.last
      r0 = instantiate_node(TripletNoteNode,input, i0...index, s0)
      r0.extend(Triplet0)
    else
      @index = i0
      r0 = nil
    end

    node_cache[:triplet][start_index] = r0

    r0
  end

  module SingleNote0
    def pl
      elements[1]
    end
  end

  module SingleNote1
    def first_pl
      elements[0]
    end

    def more_pl
      elements[1]
    end

    def art
      elements[2]
    end

    def acc
      elements[3]
    end
  end

  module SingleNote2
    def duration
      elements[0]
    end

    def more
      elements[1]
    end
  end

  def _nt_single_note
    start_index = index
    if node_cache[:single_note].has_key?(index)
      cached = node_cache[:single_note][index]
      if cached
        node_cache[:single_note][index] = cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    i0, s0 = index, []
    r1 = _nt_duration
    s0 << r1
    if r1
      i3, s3 = index, []
      r4 = _nt_pitch_link
      s3 << r4
      if r4
        s5, i5 = [], index
        loop do
          i6, s6 = index, []
          if (match_len = has_terminal?(",", false, index))
            r7 = true
            @index += match_len
          else
            terminal_parse_failure('","')
            r7 = nil
          end
          s6 << r7
          if r7
            r8 = _nt_pitch_link
            s6 << r8
          end
          if s6.last
            r6 = instantiate_node(SyntaxNode,input, i6...index, s6)
            r6.extend(SingleNote0)
          else
            @index = i6
            r6 = nil
          end
          if r6
            s5 << r6
          else
            break
          end
        end
        r5 = instantiate_node(SyntaxNode,input, i5...index, s5)
        s3 << r5
        if r5
          r10 = _nt_articulation
          if r10
            r9 = r10
          else
            r9 = instantiate_node(SyntaxNode,input, index...index)
          end
          s3 << r9
          if r9
            r12 = _nt_accent
            if r12
              r11 = r12
            else
              r11 = instantiate_node(SyntaxNode,input, index...index)
            end
            s3 << r11
          end
        end
      end
      if s3.last
        r3 = instantiate_node(SyntaxNode,input, i3...index, s3)
        r3.extend(SingleNote1)
      else
        @index = i3
        r3 = nil
      end
      if r3
        r2 = r3
      else
        r2 = instantiate_node(SyntaxNode,input, index...index)
      end
      s0 << r2
    end
    if s0.last
      r0 = instantiate_node(SingleNoteNode,input, i0...index, s0)
      r0.extend(SingleNote2)
    else
      @index = i0
      r0 = nil
    end

    node_cache[:single_note][start_index] = r0

    r0
  end

  module PitchLink0
    def pitch
      elements[0]
    end

    def the_link
      elements[1]
    end
  end

  def _nt_pitch_link
    start_index = index
    if node_cache[:pitch_link].has_key?(index)
      cached = node_cache[:pitch_link][index]
      if cached
        node_cache[:pitch_link][index] = cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    i0, s0 = index, []
    r1 = _nt_pitch
    s0 << r1
    if r1
      r3 = _nt_link
      if r3
        r2 = r3
      else
        r2 = instantiate_node(SyntaxNode,input, index...index)
      end
      s0 << r2
    end
    if s0.last
      r0 = instantiate_node(SyntaxNode,input, i0...index, s0)
      r0.extend(PitchLink0)
    else
      @index = i0
      r0 = nil
    end

    node_cache[:pitch_link][start_index] = r0

    r0
  end

  def _nt_accent
    start_index = index
    if node_cache[:accent].has_key?(index)
      cached = node_cache[:accent][index]
      if cached
        node_cache[:accent][index] = cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    if (match_len = has_terminal?("!", false, index))
      r0 = instantiate_node(SyntaxNode,input, index...(index + match_len))
      @index += match_len
    else
      terminal_parse_failure('"!"')
      r0 = nil
    end

    node_cache[:accent][start_index] = r0

    r0
  end

end

class NoteParser < Treetop::Runtime::CompiledParser
  include Note
end


end
end