module Musicality

class Score
  include Validatable
  attr_accessor :parts, :program
  
  def initialize parts: {}, program: []
    @parts = parts
    @program = program
    yield(self) if block_given?
  end

  def validatables
    @parts.values
  end
  
  def check_methods
    [:check_program_types, :check_parts_types,
     :ensure_increasing_segments, :ensure_nonnegative_segments]
  end
  
  def clone
    Marshal.load(Marshal.dump(self))
  end
  
  def ==(other)
    return @parts == other.parts && @program == other.program
  end
  
  def duration
    @parts.map {|name,part| part.duration }.max || 0.to_r
  end
  
  def collated?
    @program.size == 1 && @program[0].first == 0
  end
  
  class Timed < Score
    def seconds_long
      self.duration
    end
  end
  
  class TempoBased < Score
    attr_accessor :start_tempo, :tempo_changes

    def initialize start_tempo, tempo_changes: {}, parts: {}, program: []
      @start_tempo = start_tempo
      @tempo_changes = tempo_changes
      super(parts: parts, program: program)
      
      yield(self) if block_given?
    end
    
    def check_methods
      super() + [:check_start_tempo, :check_tempo_changes]
    end
  
    def ==(other)
      return super(other) && @start_tempo == other.start_tempo &&
      @tempo_changes == other.tempo_changes
    end
    
    def notes_long
      self.duration
    end
    
    private
    
    def check_start_tempo
      if @start_tempo <= 0
        raise NonPositiveError, "start tempo (#{@start_tempo}) is not positive"
      end
    end
    
    def check_tempo_changes
      badvalues = @tempo_changes.select {|k,v| v.end_value <= 0 }
      if badvalues.any?
        raise NonPositiveError, "tempo changes (#{badvalues}) are not positive"
      end    
    end
  end
  
  # Tempo-based score without meter, bar lines, or fixed pulse (beat).
  # Offsets are note-based, and tempo values are in quarter-notes-per-minute.
  class Unmeasured < Score::TempoBased
  end
  
  # Tempo-based score with meter, bar lines, and a fixed pulse (beat).
  # Offsets are measure-based, and tempo values are in beats-per-minute.
  class Measured < Score::TempoBased
    attr_accessor :start_meter, :meter_changes
    
    def initialize start_meter, start_tempo, meter_changes: {}, tempo_changes: {}, parts: {}, program: []
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
      super() + [ @start_meter ] + @meter_changes.values.map {|v| v.end_value}
    end
    
    def ==(other)
      return super(other) && @start_meter == other.start_meter &&
        @meter_changes == other.meter_changes
    end
    
    def measures_long note_dur = self.notes_long
      noff_end = note_dur
      noff_prev = 0.to_r
      moff_prev, mdur_prev = 0.to_r, @start_meter.measure_duration
      
      @meter_changes.sort.each do |moff,change|
        mdur = change.end_value.measure_duration
        notes_elapsed = mdur_prev * (moff - moff_prev)
        noff = noff_prev + notes_elapsed
        
        if noff >= noff_end
          break
        else
          noff_prev = noff
        end
        
        moff_prev, mdur_prev = moff, mdur
      end
      return moff_prev + Rational(noff_end - noff_prev, mdur_prev)
    end
    
    private
    
    def check_startmeter_type
      unless @start_meter.is_a? Meter
        raise TypeError, "start meter #{@start_meter} is not a Meter object"
      end
    end
    
    def check_meterchange_types
      badtypes = @meter_changes.select {|k,v| !v.end_value.is_a?(Meter) }
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
  end
  
  private
    
  def check_program_types
    non_ranges = @program.select {|x| !x.is_a?(Range) }
    if non_ranges.any?
      raise TypeError, "Non-Range program element(s) found: #{non_ranges}"
    end
  end
  
  def check_parts_types
    non_parts = @parts.values.select {|x| !x.is_a?(Part) }
    if non_parts.any?
      raise TypeError, "Non-Part part value(s) found: #{non_parts}"
    end
  end
  
  def ensure_increasing_segments
    non_increasing = @program.select {|seg| seg.first >= seg.last }
    if non_increasing.any?
      raise NonIncreasingError, "Non-increasing program range(s) found: #{non_increasing}"
    end
  end
  
  def ensure_nonnegative_segments
    negative = @program.select {|seg| seg.first < 0 || seg.last < 0 }
    if negative.any?
      raise NegativeError, "Program range(s) with negative value(s) found: #{negative}"
    end
  end
end

end
