module Musicality

class Change
  class Immediate < Change
    def offsets base_offset
      [ base_offset ]
    end
    
    def remap base_offset, map
      self.clone
    end
    
    def to_function offset, start_value
      Function::Constant.new(@end_value)
    end
  end
  
  class Gradual < Change
    def offsets base_offset
      [ base_offset, base_offset + @duration ]
    end
    
    def remap base_offset, map
      newdur = map[base_offset + @duration] - map[base_offset]
      Gradual.new(@end_value, newdur, @transition)
    end
    
    def to_function offset, start_value
      p1 = [ offset, start_value ]
      p2 = [ offset + @duration, @end_value ]
      case @transition
      when LINEAR
        Function::Linear.new(p1,p2)
      when SIGMOID
        Function::Sigmoid.new(p1,p2)
      end
    end
    
    class Trimmed < Gradual
      def offsets base_offset
        origin = base_offset - @preceding
        [ origin, base_offset, base_offset + @remaining, origin + @duration ]
      end
      
      def remap base_offset, map
        x0 = base_offset - @preceding
        y0 = map[x0]
        new_dur = map[x0 + @duration] - y0
        x1 = base_offset
        y1 = map[x1]
        Trimmed.new(@end_value, new_dur, @transition, preceding: y1 - y0,
                    remaining: map[x1 + @remaining] - y1)
      end
    end
  end
end

end