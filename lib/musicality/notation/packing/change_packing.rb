module Musicality

class Change
  class Immediate < Change
    def change_type_str; "Immediate"; end
    def pack
      { "end_value" => block_given? ? yield(@end_value) : @end_value,
        "type" => self.change_type_str }
    end
    def self.unpack packing
      end_val = packing["end_value"]
      new(block_given? ? yield(end_val) : end_val)
    end
  end
  
  class Gradual < Change
    def change_type_str; "Gradual"; end
    def pack
      packing = { "end_value" => block_given? ? yield(@end_value) : @end_value,
        "duration" => @duration, "transition" => @transition,
        "type" => self.change_type_str }
      if @start_value
        packing["start_value"] = block_given? ? yield(@start_value) : @start_value
      end
      return packing
    end
    def self.unpack packing
      start_val, end_val = packing["start_value"], packing["end_value"]
      new(block_given? ? yield(end_val) : end_val,
          packing["duration"], packing["transition"],
          start_value: (start_val.nil? || !block_given?) ? start_val : yield(start_val))
    end
    
    class Trimmed < Gradual
      def change_type_str; "Gradual::Trimmed"; end
      def pack
        packing = if block_given?
          super {|v| yield v }
        else
          super
        end
        packing.merge("preceding" => @preceding, "remaining" => @remaining)
      end
      def self.unpack packing
        g = Gradual.unpack(packing){|v| block_given? ? yield(v) : v }
        g.to_trimmed(packing["preceding"], packing["remaining"])
      end
    end
  end

  def pack
    { "end_value" => block_given? ? yield(@end_value) : @end_value,
      "type" => self.change_type_str }
  end

  def self.unpack packing
    type = const_get(packing["type"])
    if block_given?
      type.unpack(packing) {|v| yield v}
    else
      type.unpack(packing)
    end
  end  
end

end