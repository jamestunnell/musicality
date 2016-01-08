# Autogenerated from a Treetop grammar. Edits may be lost.


module Musicality
module Parsing

module Mark
  include Treetop::Runtime

  def root
    @root ||= :begin_slur
  end

  module BeginSlur0
    def to_mark; return Musicality::Mark::Slur::Begin.new; end
  end

  def _nt_begin_slur
    start_index = index
    if node_cache[:begin_slur].has_key?(index)
      cached = node_cache[:begin_slur][index]
      if cached
        node_cache[:begin_slur][index] = cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    if (match_len = has_terminal?("(", false, index))
      r0 = instantiate_node(SyntaxNode,input, index...(index + match_len))
      r0.extend(BeginSlur0)
      @index += match_len
    else
      terminal_parse_failure('"("')
      r0 = nil
    end

    node_cache[:begin_slur][start_index] = r0

    r0
  end

  module EndSlur0
    def to_mark; return Musicality::Mark::Slur::End.new; end
  end

  def _nt_end_slur
    start_index = index
    if node_cache[:end_slur].has_key?(index)
      cached = node_cache[:end_slur][index]
      if cached
        node_cache[:end_slur][index] = cached = SyntaxNode.new(input, index...(index + 1)) if cached == true
        @index = cached.interval.end
      end
      return cached
    end

    if (match_len = has_terminal?(")", false, index))
      r0 = instantiate_node(SyntaxNode,input, index...(index + match_len))
      r0.extend(EndSlur0)
      @index += match_len
    else
      terminal_parse_failure('")"')
      r0 = nil
    end

    node_cache[:end_slur][start_index] = r0

    r0
  end

end

class MarkParser < Treetop::Runtime::CompiledParser
  include Mark
end


end
end