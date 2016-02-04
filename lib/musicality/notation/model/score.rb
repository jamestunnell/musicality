module Musicality

class Score
  include Packable
  include Validatable

  special_packing(:program){|p| p.map {|range| range.to_s }}
  special_unpacking(:program){|p| p.map {|str| parse_numeric_range(str) }}

  special_packing(:sections){|s| Hash[ s.map {|name,range| [name,range.to_s] } ]}
  special_unpacking(:sections){|s| Hash[ s.map {|name,str| [name,parse_numeric_range(str)] } ]}

  attr_accessor :parts, :sections, :program, :start_key, :key_changes
  attr_writer :title, :composer

  def title value = nil
    if value.nil?
      return @title
    else
      @title = value
    end
  end

  def composer value = nil
    if value.nil?
      return @composer
    else
      @composer = value
    end
  end

  def initialize parts: {}, program: [], title: nil, composer: nil, sections: {}, start_key: Keys::C_MAJOR, key_changes: {}
    @parts = parts
    @program = program
    @title = title
    @composer = composer
    @sections = sections
    @start_key = start_key
    @key_changes = key_changes
    yield(self) if block_given?
  end

  def validatables; @parts.values; end
  def check_methods
    [:check_program, :check_parts, :check_start_key, :check_key_changes ]
  end

  def clone
    Marshal.load(Marshal.dump(self))
  end

  def ==(other)
    return self.class == other.class &&
      @parts == other.parts && @program == other.program &&
      @program == other.program && @sections == other.sections &&
      @title == other.title && @composer == other.composer &&
      @start_key == other.start_key && @key_changes == other.key_changes
  end

  def duration
    @parts.map {|name,part| part.duration }.max || 0.to_r
  end

  def collated?
    @program.size == 1 && @program[0].first == 0 && @program[0].last == duration
  end

  class Timed < Score
  end

  # Tempo-based score with meter, bar lines, and a fixed pulse (beat).
  #
  # Offsets and durations are based on note duration, but note duration is
  # determined by the tempo, which can change.
  #
  # Tempo values are in beats-per-minute.
  class Tempo < Score
    attr_accessor :start_tempo, :tempo_changes, :start_meter, :meter_changes

    # See Score#initialize for remaining kwargs
    def initialize start_meter, start_tempo, tempo_changes: {}, meter_changes: {}, parts: {}, program: [], title: nil, composer: nil, sections: {}, start_key: Keys::C_MAJOR, key_changes: {}
      @start_tempo = start_tempo
      @tempo_changes = tempo_changes
      @start_meter = start_meter
      @meter_changes = meter_changes

      super(parts: parts, program: program, title: title, composer: composer, sections: sections, start_key: start_key, key_changes: key_changes)
    end

    def check_methods
      super() + [:check_start_tempo, :check_tempo_changes, :check_start_meter, :check_meter_changes]
    end

    def validatables
      super() + [ @start_meter ] + @meter_changes.values.map {|v| v.end_value}
    end

    def ==(other)
      return super(other) &&
      @start_tempo == other.start_tempo &&
      @tempo_changes == other.tempo_changes
      @start_meter == other.start_meter &&
      @meter_changes == other.meter_changes
    end

    # Returns the measure duration of the most recent meter duration since the given note offset,
    # or of the start meter if there are no meter changes.
    def measure_duration note_offset = self.duration
      if meter_changes.any?
        candidates = meter_changes.select {|noff,change| noff <= note_offset }
        candidates.max[1].end_value.measure_duration
      else
        start_meter.measure_duration
      end
    end

    private

    def check_start_tempo
      if @start_tempo <= 0
        raise NonPositiveError, "Start tempo (#{@start_tempo}) is not positive"
      end
    end

    def check_tempo_changes
      badtypes = @tempo_changes.select {|k,v| !v.end_value.is_a?(Numeric) }
      if badtypes.any?
        raise TypeError, "Found non-numeric tempo change values: #{badtypes}"
      end

      badvalues = @tempo_changes.select {|k,v| v.end_value <= 0 }
      if badvalues.any?
        raise NonPositiveError, "Found non-positive tempo changes values: #{badvalues}"
      end
    end

    def check_start_meter
      unless @start_meter.is_a? Meter
        raise TypeError, "Start meter #{@start_meter} is not a Meter object"
      end
    end

    def check_meter_changes
      badtypes = @meter_changes.select {|k,v| !v.end_value.is_a?(Meter) }
      if badtypes.any?
        raise TypeError, "Found meter change values that are not Meter objects: #{badtypes}"
      end

      nonzero_duration = @meter_changes.select {|k,v| !v.is_a?(Change::Immediate) }
      if nonzero_duration.any?
        raise NonZeroError, "Found meter changes that are not immediate: #{nonzero_duration}"
      end
    end
  end

  private

  def check_program
    non_ranges = @program.select {|x| !x.is_a?(Range) }
    if non_ranges.any?
      raise TypeError, "Non-Range program element(s) found: #{non_ranges}"
    end

    non_increasing = @program.select {|seg| seg.first >= seg.last }
    if non_increasing.any?
      raise NonIncreasingError, "Non-increasing program range(s) found: #{non_increasing}"
    end

    negative = @program.select {|seg| seg.first < 0 || seg.last < 0 }
    if negative.any?
      raise NegativeError, "Program range(s) with negative value(s) found: #{negative}"
    end
  end

  def check_parts
    non_parts = @parts.values.select {|x| !x.is_a?(Part) }
    if non_parts.any?
      raise TypeError, "Non-Part part value(s) found: #{non_parts}"
    end
  end

  def check_start_key
    unless @start_key.is_a? Key
      raise TypeError, "Start key #{@start_key} is not a Key object"
    end
  end

  def check_key_changes
    badtypes = @key_changes.select {|k,v| !v.end_value.is_a?(Key) }
    if badtypes.any?
      raise TypeError, "Found key change values that are not Key objects: #{badtypes}"
    end

    badoffsets = @key_changes.select {|k,v| k != k.to_i }
    if badoffsets.any?
      raise NonIntegerError, "Found key changes at non-integer offsets: #{badoffsets}"
    end

    nonzero_duration = @key_changes.select {|k,v| !v.is_a?(Change::Immediate) }
    if nonzero_duration.any?
      raise NonZeroError, "Found key changes that are not immediate: #{nonzero_duration}"
    end
  end

  private

  def self.parse_numeric str
    if str.include? "."
      str.to_f
    elsif str.include? "/"
      str.to_r
    else
      str.to_i
    end
  end

  def self.parse_numeric_range str
    result = str.match /(\d+([\.\/]\d+)?)([\.]{2,3})(\d+([\.\/]\d+)?)/
    raise ArgumentError, "string #{str} is not a numeric range" if result.nil?

    dots = result.values_at(3)
    l_num = parse_numeric(result.values_at(1)[0])
    r_num = parse_numeric(result.values_at(4)[0])
    Range.new l_num, r_num, dots.size == 3
  end
end

end
