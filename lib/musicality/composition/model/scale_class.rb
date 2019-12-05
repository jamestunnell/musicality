module Musicality

# Captures a scale pattern, not applied to any specific root pitch
class ScaleClass < Intervals
  def initialize offsets
    if offsets.any? {|x| x <= 0 }
      raise NonPositiveError, "One or more offsets (#{offsets}) is non-positive"
    end

    if offsets.any? {|x| x >= 12 }
      raise ArgumentError, "One or more offsets (#{offsets}) is >= 12"
    end

    if offsets.sort != offsets
      raise ArgumentError, "Offsets (#{offsets}) are not sorted"
    end

    super(offsets)
  end
end

end
