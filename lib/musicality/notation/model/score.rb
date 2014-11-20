module Musicality

class Score
  include Validatable
  
  attr_accessor :start_tempo, :parts, :program, :tempo_changes
  
  def initialize start_tempo, tempo_changes: {}, parts: {}, program: Program.new
    @start_tempo = start_tempo
    @tempo_changes = tempo_changes
    @parts = parts
    @program = program
    
    yield(self) if block_given?
  end
  
  def check_methods
    [:check_start_tempo, :check_tempo_changes]
  end
    
  def validatables
    [ @program ] + @parts.values
  end
  
  def clone
    Marshal.load(Marshal.dump(self))
  end
  
  def ==(other)
    return @start_tempo == other.start_tempo &&
    @tempo_changes == other.tempo_changes &&
    @parts == other.parts &&
    @program == other.program
  end
    
  def duration
    @parts.map {|p| p.duration }.max
  end
  
  def check_start_tempo
    if @start_tempo <= 0
      raise NonPositiveError, "start tempo (#{@start_tempo}) is not positive"
    end
  end
  
  def check_tempo_changes
    badvalues = @tempo_changes.select {|k,v| v.value <= 0 }
    if badvalues.any?
      raise NonPositiveError, "tempo changes (#{badvalues}) are not positive"
    end    
  end
  
  # Score without meter, bar lines, or fixed pulse (beat). Offsets are
  # note-based, and tempo values are in quarter-notes-per-minute.
  class Unmeasured < Score
  end
  
  # Score with meter, bar lines, and a fixed pulse (beat). Offsets are
  # measure-based, and tempo values are in beats-per-minute.
  class Measured < Score
    attr_accessor :start_meter, :meter_changes
    
    def initialize start_meter, start_tempo, meter_changes: {}, tempo_changes: {}, parts: {}, program: Program.new
      @start_meter = start_meter
      @meter_changes = meter_changes
      
      super(start_tempo, tempo_changes: tempo_changes,
            program: program, parts: parts)
      yield(self) if block_given?
    end
    
    def check_methods
      super() + [:check_startmeter_type, :check_meterchange_types,
                 :check_meterchange_durs, :check_meterchange_offsets]
    end
    
    def validatables
      super() + [ @start_meter ] + @meter_changes.values.map {|v| v.value}
    end
    
    def check_startmeter_type
      unless @start_meter.is_a? Meter
        raise TypeError, "start meter #{@start_meter} is not a Meter object"
      end
    end
    
    def check_meterchange_types
      badtypes = @meter_changes.select {|k,v| !v.value.is_a?(Meter) }
      if badtypes.any?
        raise TypeError, "meter change values #{nonmeter_values} are not Meter objects"
      end
    end
    
    def check_meterchange_offsets
      badoffsets = @meter_changes.select {|k,v| k != k.to_i }
      if badoffsets.any?
        raise NonIntegerError, "meter changes #{badoffsets} have non-integer offsets"
      end
    end
    
    def check_meterchange_durs
      nonzero_duration = @meter_changes.select {|k,v| !v.is_a?(Change::Immediate) }
      if nonzero_duration.any?
        raise NonZeroError, "meter changes #{nonzero_duration} are not immediate"
      end
    end
    
    def ==(other)
      return super(other) && @start_meter == other.start_meter &&
        @meter_changes == other.meter_changes
    end
  end
end

end