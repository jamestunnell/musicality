module Musicality

# Score with note-based offsets. Tempo values are in quarter-notes-per-second.
class NoteScore
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
end

end
