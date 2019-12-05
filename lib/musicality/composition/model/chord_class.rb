module Musicality

# Captures a chord pattern, not applied to any specific root pitch
class ChordClass < Intervals
  def initialize offsets
    if offsets.any? {|x| x <= 0 }
      raise NonPositiveError, "One or more offsets (#{offsets}) is non-positive"
    end

    if offsets.sort != offsets
      raise ArgumentError, "Scale offsets (#{offsets}) are not sorted"
    end

    super(offsets)
  end
end

end
