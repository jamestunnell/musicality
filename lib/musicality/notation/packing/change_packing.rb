module Musicality

class Change
  class Immediate < Change
    def change_type_str; "Immediate"; end
    def pack; super(); end
    def self.unpack(packing)
      new(packing["end_value"])
    end
  end
  
  class Gradual < Change
    def change_type_str; "Gradual"; end
    def pack
      super().merge("duration" => @duration, "transition" => @transition,
                    "start_value" => @start_value)
    end
    def self.unpack packing
      new(packing["end_value"], packing["duration"], packing["transition"],
          start_value: packing["start_value"])
    end
    
    class Trimmed < Gradual
      def change_type_str; "Gradual::Trimmed"; end
      def pack
        super().merge("preceding" => @preceding, "remaining" => @remaining)
      end
      def self.unpack packing
        Gradual.unpack(packing).to_trimmed(packing["preceding"], packing["remaining"])
      end
    end
  end

  def pack
    { "end_value" => @end_value, "type" => self.change_type_str }
  end

  def self.unpack packing
    type = const_get(packing["type"])
    type.unpack(packing)
  end  
end

end