module Musicality

class Change
  class Immediate < Change
    def offsets base_offset
      [ base_offset ]
    end
  end
  
  class Gradual < Change
    def offsets base_offset
      initial = base_offset - @elapsed
      final = initial + @total_duration
      [ initial, base_offset, base_offset + @impending, final ]
    end
  end
end

end