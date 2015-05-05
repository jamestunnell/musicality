module Musicality

require 'set'

class Note
  include Validatable
  
  attr_reader :pitches, :links, :duration
  attr_accessor :articulation, :accented

  DEFAULT_ARTICULATION = Articulations::NORMAL
  
  def initialize duration, pitches = [], articulation: DEFAULT_ARTICULATION, accented: false, links: {}
    self.duration = duration
    if !pitches.is_a? Enumerable
      pitches = [ pitches ]
    end
    @pitches = Set.new(pitches).sort
    @articulation = articulation
    @accented = accented
    @links = links
  end
  
  def check_methods
    [ :check_pitches ]
  end
  
  def check_pitches
    non_pitches = @pitches.select {|p| !p.is_a?(Pitch) }
    if non_pitches.any?
      raise TypeError, "Found non-pitches: #{non_pitches}"
    end
  end
  
  def == other
    return (@duration == other.duration) &&
    (self.pitches == other.pitches) &&
    (@links.to_a.sort == other.links.to_a.sort) &&
    (@articulation == other.articulation) &&
    (@accented == other.accented)
  end
  
  def clone
    Marshal.load(Marshal.dump(self))
  end

  def duration=  duration
    raise NonPositiveError, "duration #{duration} is not positive" unless duration > 0
    #@duration = duration.is_a?(Duration) ? duration : duration.to_dur
    @duration = duration
  end

  def resize duration
    new_note = self.clone
    new_note.duration = duration
    return new_note
  end

  def transpose diff
    self.clone.transpose! diff
  end
  
  def transpose! diff
    @pitches = @pitches.map {|pitch| pitch.transpose(diff) }
    @links = Hash[ @links.map do |k,v|
      [ k.transpose(diff), v.transpose(diff) ]
    end ]
    return self
  end

  def to_s
    d = @duration.to_r
    if d.denominator == 1
      dur_str = "#{d.numerator}"
    elsif d.numerator == 1
      dur_str = "/#{d.denominator}"
    else
      dur_str = d.to_s
    end

    pitch_links_str = @pitches.map do |p|
      if @links.has_key?(p)
        p.to_s + @links[p].to_s
      else
        p.to_s
      end
    end.join(",")

    art_str = ARTICULATION_SYMBOLS[@articulation] || ""
    acc_str = @accented ? ACCENT_SYMBOL : ""

    return dur_str + pitch_links_str + art_str + acc_str
  end

  def self.add_note_method(name, dur)
    self.class.send(:define_method,name.to_sym) do |pitches = [], articulation: DEFAULT_ARTICULATION, links: {}, accented: false|
      Note.new(dur, pitches, articulation: articulation, links: links, accented: accented)
    end
  end
  
  {
    :sixteenth => Rational(1,16),
    :dotted_sixteenth => Rational(3,32),
    :eighth => Rational(1,8),
    :dotted_eighth => Rational(3,16),
    :quarter => Rational(1,4),
    :dotted_quarter => Rational(3,8),
    :half => Rational(1,2),
    :dotted_half => Rational(3,4),
    :whole => Rational(1),
  }.each do |meth_name, dur|
    add_note_method meth_name, dur
  end
end

end
