module Musicality

class Change
  class Immediate < Change
    def offsets base_offset
      [ base_offset ]
    end
    
    def remap base_offset, map
      self.clone
    end
    
    def to_transition offset, start_value
      Transition::Immediate.new([offset,start_value],[offset,@end_value])
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
    
    def to_transition offset, start_value
      p0 = [ offset, start_value ]
      p1 = [ offset + @duration, @end_value ]
      case @transition
      when LINEAR
        Transition::Linear.new(p0,p1)
      when SIGMOID
        Transition::Sigmoid.new(p0,p1)
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
      
      def to_transition offset, start_value
        x0 = offset - @preceding
        x1 = x0 + @duration
        
        case @transition
        when LINEAR
          lin = Function::Linear.new([offset,start_value],[x1, @end_value])
          p0, p1 = [x0, lin.at(x0)], [x1, @end_value ]
          x_ = offset + @remaining
          y_ = lin.at(x_)
          Transition.new([offset, start_value],[x_, y_],Function::Linear.new(p0,p1))
        when SIGMOID
          y_ = inv_sigm(x0..x1, offset)
          y__ = inv_sigm(x0..x1, offset + @remaining)
          lin = Function::Linear.new([y_,start_value],[1, @end_value])
          p0, p1 = [x0, lin.at(0)], [x1, @end_value]
          Transition.new([offset, start_value],[offset + @remaining, lin.at(y__)],Function::Sigmoid.new(p0,p1))
        end
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