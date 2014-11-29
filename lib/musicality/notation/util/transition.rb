module Musicality

class Transition < Function::Piecewise
  def initialize p0, p1, transition_function = nil
    super()
    add_piece(-Float::INFINITY..p0[0], Function::Constant.new(p0[1]))
    unless transition_function.nil?
      add_piece(p0[0]..p1[0], transition_function)
    end
    add_piece(p1[0]..Float::INFINITY, Function::Constant.new(p1[1]))
  end
  
  class Immediate < Transition
    def initialize p0, p1
      super(p0,p1)
    end
  end
  
  class Linear < Transition
    def initialize p0, p1
      super(p0,p1,Function::Linear.new(p0,p1))
    end    
  end
  
  class Sigmoid < Transition
    def initialize p0, p1
      super(p0,p1,Function::Sigmoid.new(p0,p1))
    end    
  end
end

end
