module Musicality

class Part
  include Packable
  include Validatable
  
  special_packing(:notes) {|notes| notes.map {|n| n.to_s }.join(" ") }
  special_unpacking(:notes) {|notes_str| Note.split_parse(notes_str) }

  attr_accessor :start_dynamic, :dynamic_changes, :notes, :settings
  
  def initialize start_dynamic, notes: [], dynamic_changes: {}, settings: []
    @notes = notes
    @start_dynamic = start_dynamic
    @dynamic_changes = dynamic_changes
    @settings = settings

    yield(self) if block_given?
  end
  
  def check_methods
    [:check_start_dynamic, :check_dynamic_changes]
  end
  
  def validatables
    @notes
  end
  
  def clone
    Marshal.load(Marshal.dump(self))
  end
  
  def ==(other)
    return (@notes == other.notes) &&
    (@start_dynamic == other.start_dynamic) &&
    (@dynamic_changes == other.dynamic_changes)
  end

  def duration
    return @notes.inject(0) { |sum, note| sum + note.duration }
  end
  
  def check_start_dynamic
    unless @start_dynamic.between?(0,1)
      raise RangeError, "start dynamic #{@start_dynamic} is not between 0 and 1"
    end
  end
  
  def check_dynamic_changes
    outofrange = @dynamic_changes.values.select {|v| !v.end_value.between?(0,1) }
    if outofrange.any?
      raise RangeError, "dynamic change values #{outofrange} are not between 0 and 1"
    end
  end

  def transpose interval
    p = self.clone
    p.notes.each {|n| n.transpose!(interval) }
    return p
  end

  def find_settings settings_class
    settings.find {|s| s.is_a? settings_class }
  end
end

end
