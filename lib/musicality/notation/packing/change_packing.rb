module Musicality

class Change
  class Immediate < Change
    def change_type_str; "Immediate"; end
    def pack with: nil
      super(:with => with)
    end
    
    def self.unpack(packing, with: nil)
      end_val = packing["end_value"]
      new(with.nil? ? end_val : end_val.send(with))
    end
  end
  
  class Gradual < Change
    def change_type_str; "Gradual"; end
    def pack with: nil
      packing = super(:with => with)
      packing.merge!("duration" => @duration, "transition" => @transition)
      unless @start_value.nil?
        packing["start_value"] = with.nil? ? @start_value : @start_value.send(with)
      end
      return packing
    end
    def self.unpack packing, with: nil
      start_val, end_val = packing["start_value"], packing["end_value"]
      new(with.nil? ? end_val : end_val.send(with),
          packing["duration"], packing["transition"],
          start_value: (start_val.nil? || with.nil?) ? start_val : start_val.send(with))
    end
    
    class Trimmed < Gradual
      def change_type_str; "Gradual::Trimmed"; end
      def pack with: nil
        super(:with => with).merge("preceding" => @preceding, "remaining" => @remaining)
      end
      def self.unpack packing, with: nil
        Gradual.unpack(packing, :with => with).to_trimmed(
          packing["preceding"], packing["remaining"])
      end
    end
  end

  def pack with: nil
    { "end_value" => (with.nil? ? @end_value : @end_value.send(with)),
      "type" => self.change_type_str }
  end

  def self.unpack packing, with: nil
    type = const_get(packing["type"])
    type.unpack(packing, with: with)
  end  
end

end