require 'yaml'

module Musicality

class Part
  include Validatable
  
  attr_accessor :start_dynamic, :dynamic_changes, :notes
  
  def initialize start_dynamic, notes: [], dynamic_changes: {}
    @notes = notes
    @start_dynamic = start_dynamic
    @dynamic_changes = dynamic_changes
    
    yield(self) if block_given?
  end
  
  def check_methods
    [:ensure_start_dynamic, :ensure_dynamic_change_values_range ]
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
  
  def ensure_start_dynamic
    unless @start_dynamic.between?(0,1)
      raise RangeError, "start dynamic #{@start_dynamic} is not between 0 and 1"
    end
  end
  
  def ensure_dynamic_change_values_range
    outofrange = @dynamic_changes.values.select {|v| !v.value.between?(0,1) }
    if outofrange.any?
      raise RangeError, "dynamic change values #{outofrange} are not between 0 and 1"
    end
  end
end

end
