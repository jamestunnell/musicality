module Musicality

class Change
  class Immediate < Change
    def pack
      pack_common
    end
    
    def self.unpack packing
      new(packing["value"])
    end
  end
  
  class Gradual < Change
    def pack
      packing = pack_common.merge("impending" => @impending)
      unless @remaining == 0
        packing["remaining"] = @remaining
      end
      unless @elapsed == 0
        packing["elapsed"] = @elapsed
      end
      return packing
    end
    
    def self.unpack packing
      elapsed = packing["elapsed"] || 0
      remaining = packing["remaining"] || 0
      new(packing["value"], packing["impending"], elapsed, remaining)
    end
  end

  def self.unpack packing
    type = const_get(packing["type"])
    type.unpack(packing)
  end
  
  private
  
  def pack_common
    { "type" => self.class.to_s.split("::")[-1],
      "value" => @value }
  end
end

end