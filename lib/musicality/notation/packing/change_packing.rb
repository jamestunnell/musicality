module Musicality

class Change
  class Immediate < Change
    def pack
      [ @value ]
    end
  end
  
  class Gradual < Change
    def pack
      [ @value, @duration, @elapsed, @remaining ]
    end
  end

  def self.unpack packing
    case packing.size
    when 1 then Immediate.new(*packing)
    when 4 then Gradual.new(*packing)
    else raise ArgumentError, "bad array size"
    end
  end
end

end