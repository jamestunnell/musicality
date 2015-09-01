module Musicality

class Score
  class Timed < Score
    def pack
      pack_common
    end
    
    def self.unpack packing
      new(**Score.unpack_common(packing))
    end
  end
  
  class Tempo < Score
    def pack
      pack_common.merge("start_tempo" => @start_tempo,
        "tempo_changes" => pack_tempo_changes,
        "start_meter" => start_meter.pack,
        "meter_changes" => pack_meter_changes)
    end
    
    def pack_tempo_changes
      Hash[ tempo_changes.map do |offset,change|
        [offset,change.pack]
      end ]
    end

    def self.unpack_tempo_changes packing
      Hash[ packing["tempo_changes"].map do |k,v|
        [k, Change.unpack(v) ]
      end ]
    end

    def pack_meter_changes
      Hash[ meter_changes.map do |off,change|
        [off, change.pack {|v| v.pack }]
      end ]
    end

    def self.unpack_meter_changes packing
      Hash[ packing["meter_changes"].map do |off,p|
         [off, Change.unpack(p){ |v| Meter.unpack(v) }]
      end ]
    end

    def self.unpack packing
      a = new(Meter.unpack(packing["start_meter"]), packing["start_tempo"],
        tempo_changes: unpack_tempo_changes(packing),
        meter_changes: unpack_meter_changes(packing),
        **Score.unpack_common(packing))
    end
  end
  
  def self.unpack packing
    type = const_get(packing["type"])
    type.unpack(packing)
  end
  
  private
  
  def pack_parts
    Hash[ @parts.map do |name,part|
        [ name, part.pack ]
    end ]
  end

  def self.unpack_parts packing
    Hash[ packing["parts"].map do |name,packed|
      [name, Part.unpack(packed)]
    end ]
  end

  def pack_program
    @program.map {|seg| seg.to_s }
  end

  def self.unpack_program packing
    packing["program"].map {|str| Segment.parse(str) }
  end

  def pack_key_changes
    Hash[ key_changes.map do |off,change|
      [off, change.pack {|v| v.pack }]
    end ]
  end

  def self.unpack_key_changes packing
    Hash[ packing["key_changes"].map do |off,p|
       [off, Change.unpack(p){|v| Key.unpack(v) }]
    end ]
  end

  def pack_common
    { "type" => self.class.to_s.split("::")[-1],
      "program" => pack_program,
      "parts" => pack_parts,
      "title" => @title,
      "composer" => @composer,
      "start_key" => @start_key.pack,
      "key_changes" => pack_key_changes
    }
  end
  
  def self.unpack_common packing
    { :program => unpack_program(packing),
      :parts => unpack_parts(packing),
      :title => packing["title"],
      :composer => packing["composer"],
      :start_key => Key.unpack(packing["start_key"]),
      :key_changes => unpack_key_changes(packing)
    }
  end    
end

end