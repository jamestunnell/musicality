module Musicality

class Change
  class Immediate < Change
    def offsets base_offset
      [ base_offset ]
    end
    
    def remap base_offset, map
      self.clone
    end
    
    def to_transition offset, value
      Transition::new(Function::Constant.new(@end_value), offset..offset)
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
    
    def to_transition offset, value
      p1 = [ offset, @start_value || value ]
      p2 = [ offset + @duration, @end_value ]
      func = case @transition
      when LINEAR then Function::Linear.new(p1, p2)
      when SIGMOID then Function::Sigmoid.new(p1, p2)
      end
      Transition.new(func, p1[0]..p2[0])
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
      
      def to_transition offset, value
        x1,x2,x3 = offset - @preceding, offset, offset + @remaining
        x4 = x1 + @duration
        func = case @transition
        when LINEAR
          Function::Linear.new(@start_value.nil? ? [x2,value] : [x1,@start_value],[x4, @end_value])
        when SIGMOID
          y1 = @start_value || Function::Sigmoid.find_y0(x1..x4, [x2, value], @end_value)
          Function::Sigmoid.new([x1,y1],[x4, @end_value])
        end
        Transition.new(func, x2..x3)
      end
      
      private
      
      def inv_sigm start_domain, x
        sigm_domain = Function::Sigmoid::SIGM_DOMAIN
        x_ = Function.transform_domains(start_domain, sigm_domain, x)
        dy = Function::Sigmoid::sigm(sigm_domain.last) - Function::Sigmoid::sigm(sigm_domain.first)
        (Function::Sigmoid::sigm(x_) - Function::Sigmoid::sigm(sigm_domain.first)) / dy
      end
    end
  end
end

end