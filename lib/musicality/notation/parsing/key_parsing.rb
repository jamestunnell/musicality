# Autogenerated from a Treetop grammar. Edits may be lost.


module Musicality
module Parsing

module Key
  include Treetop::Runtime

  def root
    @root ||= :key
  end

  include Pitch

  module Key0
    def pitch_letter
      elements[0]
    end

    def mod
      elements[1]
    end

    def major_minor
      elements[2]
    end
  end

  module Key1
    def to_key
      sem = pitch_letter.to_semitone
      modval = 0
      if !mod.empty?
        modval = case mod.text_value
        when "#" then 1
        when "b" then -1
        end
      end

      triad_type = if major_minor.text_value.include?("maj")
        Musicality::Key::MAJOR
      else
        Musicality::Key::MINOR
      end

      return Musicality::Key.new(sem + modval, triad_type: triad_type)
    end
  end

  def _nt_key
    start_index = index
    if node_cache[:key].has_key?(index)
      cached = node_cache[:key][index]
      if cached
        node_cache[:key][index] = cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    i0, s0 = index, []
    r1 = _nt_pitch_letter
    s0 << r1
    if r1
      if has_terminal?(@regexps[gr = '\A[#b]'] ||= Regexp.new(gr), :regexp, index)
        r3 = true
        @index += 1
      else
        terminal_parse_failure('[#b]')
        r3 = nil
      end
      if r3
        r2 = r3
      else
        r2 = instantiate_node(SyntaxNode,input, index...index)
      end
      s0 << r2
      if r2
        r4 = _nt_major_minor
        s0 << r4
      end
    end
    if s0.last
      r0 = instantiate_node(SyntaxNode,input, i0...index, s0)
      r0.extend(Key0)
      r0.extend(Key1)
    else
      @index = i0
      r0 = nil
    end

    node_cache[:key][start_index] = r0

    r0
  end

  def _nt_major_minor
    start_index = index
    if node_cache[:major_minor].has_key?(index)
      cached = node_cache[:major_minor][index]
      if cached
        node_cache[:major_minor][index] = cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    i0 = index
    if (match_len = has_terminal?("maj", false, index))
      r1 = instantiate_node(SyntaxNode,input, index...(index + match_len))
      @index += match_len
    else
      terminal_parse_failure('"maj"')
      r1 = nil
    end
    if r1
      r1 = SyntaxNode.new(input, (index-1)...index) if r1 == true
      r0 = r1
    else
      if (match_len = has_terminal?("min", false, index))
        r2 = instantiate_node(SyntaxNode,input, index...(index + match_len))
        @index += match_len
      else
        terminal_parse_failure('"min"')
        r2 = nil
      end
      if r2
        r2 = SyntaxNode.new(input, (index-1)...index) if r2 == true
        r0 = r2
      else
        @index = i0
        r0 = nil
      end
    end

    node_cache[:major_minor][start_index] = r0

    r0
  end

end

class KeyParser < Treetop::Runtime::CompiledParser
  include Key
end


end
end